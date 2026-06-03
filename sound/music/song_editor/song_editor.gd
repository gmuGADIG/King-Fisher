extends Control
class_name SongEditor

## Song Resource Editor
## Features:
## - Visual timeline with draggable section markers
## - Multiple sections support with add/remove/select
## - Inline curve editors for crossfade
## - Fine-tune controls with arrow key support

@export var song_path: String

# Node references
@onready var music_player: MusicPlayer = $MusicPlayer
@onready var song_scanner: Node = $SongScanner
@onready var timeline: SongTimeline = %Timeline
@onready var file_dropdown: OptionButton = %FileDropdown
@onready var load_btn: Button = %LoadBtn
@onready var time_display: Label = %TimeDisplay

# Playback controls
@onready var play_btn: Button = %PlayBtn
@onready var stop_btn: Button = %StopBtn
@onready var play_section_btn: Button = %PlaySectionBtn
@onready var preview_loop_btn: Button = %PreviewLoopBtn
@onready var volume_slider: HSlider = %VolumeSlider

# Section controls (left column)
@onready var loop_checkbox: CheckBox = %LoopCheckbox
@onready var section_start_spin: SpinBox = %SectionStartSpin
@onready var section_end_spin: SpinBox = %SectionEndSpin
@onready var crossfade_spin: SpinBox = %CrossfadeSpin

# Section management (right column)
@onready var section_dropdown: OptionButton = %SectionDropdown
@onready var rename_section_btn: Button = %RenameSectionBtn
@onready var add_section_btn: Button = %AddSectionBtn
@onready var remove_section_btn: Button = %RemoveSectionBtn

# Global controls
@onready var gain_slider: HSlider = %GainSlider
@onready var gain_label: Label = %GainValueLabel

# Curve editors
@onready var fade_in_curve_edit: SongCurveEditor = %FadeInCurve
@onready var fade_out_curve_edit: SongCurveEditor = %FadeOutCurve
@onready var reset_fade_in_btn: Button = %ResetFadeInBtn
@onready var reset_fade_out_btn: Button = %ResetFadeOutBtn

# Save section
@onready var save_path_edit: LineEdit = %SavePathEdit
@onready var save_btn: Button = %SaveBtn

# Toast notification
@onready var toast: PanelContainer = %Toast
@onready var toast_label: Label = %ToastLabel
var _toast_timer: float = 0.0

# Current song and section being edited
var _current_song: Song
var _current_section_idx: int = 0

func _ready() -> void:
	song_scanner.root_path = song_path
	song_scanner.index_all_sound_files_in_root_directory()
	_setup_file_dropdown()
	_connect_signals()
	_sync_ui_from_song()

func _process(delta: float) -> void:
	_update_playhead()
	_update_toast(delta)

func _setup_file_dropdown() -> void:
	file_dropdown.clear()
	file_dropdown.add_item("-- Select Audio File --")
	for file: Resource in song_scanner.sound_files:
		file_dropdown.add_item(file.resource_path)

func _connect_signals() -> void:
	load_btn.pressed.connect(_on_load_pressed)
	timeline.loop_start_changed.connect(_on_timeline_section_start_changed)
	timeline.loop_end_changed.connect(_on_timeline_section_end_changed)
	timeline.seek_requested.connect(_on_timeline_seek)
	timeline.marker_selected.connect(_on_marker_selected)
	
	# Playback
	play_btn.pressed.connect(_on_play_pressed)
	stop_btn.pressed.connect(_on_stop_pressed)
	play_section_btn.pressed.connect(_on_play_section_pressed)
	preview_loop_btn.pressed.connect(_on_preview_loop_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	
	# Section controls
	loop_checkbox.toggled.connect(_on_loop_toggled)
	section_start_spin.value_changed.connect(_on_section_start_spin_changed)
	section_end_spin.value_changed.connect(_on_section_end_spin_changed)
	crossfade_spin.value_changed.connect(_on_crossfade_changed)
	
	# Section management
	section_dropdown.item_selected.connect(_on_section_selected)
	rename_section_btn.pressed.connect(_on_rename_section_pressed)
	add_section_btn.pressed.connect(_on_add_section_pressed)
	remove_section_btn.pressed.connect(_on_remove_section_pressed)
	
	# Global
	gain_slider.value_changed.connect(_on_gain_changed)
	
	# Curves
	reset_fade_in_btn.pressed.connect(_on_reset_fade_in)
	reset_fade_out_btn.pressed.connect(_on_reset_fade_out)
	
	# Save
	save_btn.pressed.connect(_on_save_pressed)

func _on_load_pressed() -> void:
	var index := file_dropdown.selected
	if index <= 0:
		_show_toast("Select an audio file first", Color(1.0, 0.6, 0.4))
		return
	
	# Stop any current playback and reset state
	music_player.stop()
	
	var file_path: String = file_dropdown.get_item_text(index)
	var resource: Resource = load(file_path)
	
	if resource is Song:
		_current_song = resource.duplicate(true)
		save_path_edit.text = file_path
	elif resource is AudioStream:
		var song := Song.new()
		song.song_file = resource
		# Create default section
		var default_section := Section.new("main loop", 0.0, resource.get_length(), true)
		song.sections.append(default_section)
		_current_song = song
		save_path_edit.text = file_path.get_basename() + ".tres"
	
	_current_section_idx = 0
	_rebuild_section_dropdown()
	_sync_ui_from_song()
	_setup_curve_editors()
	
	_show_toast("Loaded: " + file_path.get_file(), Color(0.4, 0.8, 0.5))

func _get_current_section() -> Section:
	if not _current_song or _current_song.sections.is_empty():
		return null
	if _current_section_idx >= _current_song.sections.size():
		_current_section_idx = 0
	return _current_song.sections[_current_section_idx]

func _rebuild_section_dropdown() -> void:
	section_dropdown.clear()
	if not _current_song:
		return
	
	for i in _current_song.sections.size():
		var section: Section = _current_song.sections[i]
		var name: String = section.section_name if section.section_name != "" else "Section %d" % (i + 1)
		section_dropdown.add_item(name)
	
	if _current_song.sections.size() > 0:
		section_dropdown.select(_current_section_idx)

func _sync_ui_from_song() -> void:
	if not _current_song:
		return
	
	var length: float = 0.0
	if _current_song.song_file and _current_song.song_file is AudioStream:
		length = _current_song.song_file.get_length()
	
	timeline.set_song_length(length)
	
	# Set spin box max values
	section_start_spin.max_value = length
	section_end_spin.max_value = length
	crossfade_spin.max_value = length * 0.5
	
	# Sync gain
	gain_slider.set_value_no_signal(_current_song.amplify_db)
	_update_gain_label(_current_song.amplify_db)
	
	# Sync current section
	var section := _get_current_section()
	if section:
		loop_checkbox.set_pressed_no_signal(section.loop)
		section_start_spin.set_value_no_signal(section.section_start)
		section_end_spin.set_value_no_signal(section.section_end)
		crossfade_spin.set_value_no_signal(section.fade_period)
		
		timeline.set_loop_start(section.section_start)
		timeline.set_loop_end(section.section_end)
		timeline.set_fade_period(section.fade_period)
	
	# Update remove button state
	remove_section_btn.disabled = _current_song.sections.size() <= 1

func _setup_curve_editors() -> void:
	var section := _get_current_section()
	if not section:
		return
	
	fade_in_curve_edit.set_curve(section.fade_in_curve)
	fade_out_curve_edit.set_curve(section.fade_out_curve)

func _update_playhead() -> void:
	var pos := music_player.get_position()
	var length := music_player.get_length()
	
	timeline.set_playhead_position(pos)
	
	if length > 0:
		time_display.text = "%s / %s" % [_format_time(pos), _format_time(length)]
	else:
		time_display.text = "--:-- / --:--"
	
	_update_curve_playheads(pos)

func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]

func _update_curve_playheads(pos: float) -> void:
	var section := _get_current_section()
	if not section:
		fade_in_curve_edit.set_playhead(-1.0)
		fade_out_curve_edit.set_playhead(-1.0)
		return
	
	var fade_start := section.section_end - section.fade_period
	
	if pos >= fade_start and pos < section.section_end and section.fade_period > 0:
		var t := (pos - fade_start) / section.fade_period
		t = clampf(t, 0.0, 1.0)
		fade_in_curve_edit.set_playhead(t)
		fade_out_curve_edit.set_playhead(t)
	else:
		fade_in_curve_edit.set_playhead(-1.0)
		fade_out_curve_edit.set_playhead(-1.0)

# =============================================================================
# PLAYBACK HANDLERS
# =============================================================================

func _on_play_pressed() -> void:
	if not _current_song:
		return
	if music_player.is_playing():
		music_player.stop()
	music_player.play_song(_current_song, 0.0, 0.0)

func _on_stop_pressed() -> void:
	music_player.stop()

func _on_play_section_pressed() -> void:
	var section := _get_current_section()
	if not section or not _current_song:
		return
	if music_player.is_playing():
		music_player.seek(section.section_start)
	else:
		music_player.play_song(_current_song, section.section_start, 0.0)

func _on_preview_loop_pressed() -> void:
	var section := _get_current_section()
	if not section or not _current_song:
		return
	var preview_start := maxf(0.0, section.section_end - 3.0)
	if music_player.is_playing():
		music_player.seek(preview_start)
	else:
		music_player.play_song(_current_song, preview_start, 0.0)

func _on_volume_changed(value: float) -> void:
	music_player.set_volume(value)

# =============================================================================
# TIMELINE HANDLERS
# =============================================================================

func _on_timeline_section_start_changed(value: float) -> void:
	var section := _get_current_section()
	if section:
		section.section_start = value
		section_start_spin.set_value_no_signal(value)

func _on_timeline_section_end_changed(value: float) -> void:
	var section := _get_current_section()
	if section:
		section.section_end = value
		section_end_spin.set_value_no_signal(value)

func _on_timeline_seek(seek_position: float) -> void:
	if not _current_song:
		return
	if music_player.is_playing():
		music_player.seek(seek_position)
	else:
		music_player.play_song(_current_song, seek_position, 0.0)

func _on_marker_selected(_marker: String) -> void:
	pass

# =============================================================================
# SECTION CONTROL HANDLERS (Left Column)
# =============================================================================

func _on_loop_toggled(pressed: bool) -> void:
	var section := _get_current_section()
	if section:
		section.loop = pressed

func _on_section_start_spin_changed(value: float) -> void:
	var section := _get_current_section()
	if section:
		section.section_start = value
		timeline.set_loop_start(value)

func _on_section_end_spin_changed(value: float) -> void:
	var section := _get_current_section()
	if section:
		section.section_end = value
		timeline.set_loop_end(value)

func _on_crossfade_changed(value: float) -> void:
	var section := _get_current_section()
	if section:
		section.fade_period = value
		timeline.set_fade_period(value)

# =============================================================================
# SECTION MANAGEMENT HANDLERS (Right Column)
# =============================================================================

func _on_section_selected(index: int) -> void:
	_current_section_idx = index
	_sync_ui_from_song()
	_setup_curve_editors()

func _on_rename_section_pressed() -> void:
	var section := _get_current_section()
	if not section:
		return
	
	# Create a simple rename dialog
	var dialog := AcceptDialog.new()
	dialog.title = "Rename Section"
	dialog.ok_button_text = "Rename"
	
	var line_edit := LineEdit.new()
	line_edit.text = section.section_name
	line_edit.placeholder_text = "Section name..."
	line_edit.custom_minimum_size = Vector2(250, 0)
	line_edit.select_all_on_focus = true
	dialog.add_child(line_edit)
	
	dialog.confirmed.connect(func() -> void:
		var new_name: String = line_edit.text
		section.section_name = new_name
		var display_name: String = new_name if new_name != "" else "Section %d" % (_current_section_idx + 1)
		section_dropdown.set_item_text(_current_section_idx, display_name)
		dialog.queue_free()
	)
	dialog.canceled.connect(func() -> void:
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()
	line_edit.grab_focus()

func _on_add_section_pressed() -> void:
	if not _current_song:
		return
	
	var length: float = 0.0
	if _current_song.song_file and _current_song.song_file is AudioStream:
		length = _current_song.song_file.get_length()
	
	var new_section := Section.new("new section", 0.0, length, false)
	_current_song.sections.append(new_section)
	
	_current_section_idx = _current_song.sections.size() - 1
	_rebuild_section_dropdown()
	_sync_ui_from_song()
	_setup_curve_editors()
	
	_show_toast("Section added", Color(0.4, 0.8, 0.5))

func _on_remove_section_pressed() -> void:
	if not _current_song or _current_song.sections.size() <= 1:
		return
	
	_current_song.sections.remove_at(_current_section_idx)
	_current_section_idx = mini(_current_section_idx, _current_song.sections.size() - 1)
	
	_rebuild_section_dropdown()
	_sync_ui_from_song()
	_setup_curve_editors()
	
	_show_toast("Section removed", Color(1.0, 0.6, 0.4))

# =============================================================================
# GLOBAL HANDLERS
# =============================================================================

func _on_gain_changed(value: float) -> void:
	if _current_song:
		_current_song.amplify_db = value
		music_player.refresh_amplify()
		_update_gain_label(value)

func _update_gain_label(value: float) -> void:
	var sign_str: String = "+" if value > 0 else ""
	gain_label.text = "%s%.1f dB" % [sign_str, value]

# =============================================================================
# CURVE HANDLERS
# =============================================================================

func _on_reset_fade_in() -> void:
	var section := _get_current_section()
	if section:
		var curve: Curve = Section.new().fade_in_curve
		section.fade_in_curve = curve
		fade_in_curve_edit.set_curve(curve)

func _on_reset_fade_out() -> void:
	var section := _get_current_section()
	if section:
		var curve: Curve = Section.new().fade_out_curve
		section.fade_out_curve = curve
		fade_out_curve_edit.set_curve(curve)

# =============================================================================
# SAVE HANDLER
# =============================================================================

func _on_save_pressed() -> void:
	if not _current_song:
		_show_toast("No song loaded", Color(1.0, 0.6, 0.4))
		return
	
	var path := save_path_edit.text.strip_edges()
	if path.is_empty():
		_show_toast("Enter a save path", Color(1.0, 0.6, 0.4))
		return
	
	if not path.begins_with("res://"):
		path = song_path + path
	
	if not path.ends_with(".tres"):
		path += ".tres"
	
	var err := ResourceSaver.save(_current_song, path)
	if err == OK:
		_show_toast("Saved!", Color(0.4, 0.8, 0.5))
		save_path_edit.text = path
	else:
		_show_toast("Save failed: " + str(err), Color(1.0, 0.4, 0.4))

# =============================================================================
# TOAST
# =============================================================================

func _show_toast(message: String, color: Color = Color(0.9, 0.9, 0.9)) -> void:
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", color)
	toast.visible = true
	toast.modulate.a = 1.0
	_toast_timer = 2.0

func _update_toast(delta: float) -> void:
	if _toast_timer > 0:
		_toast_timer -= delta
		if _toast_timer <= 0.5:
			toast.modulate.a = _toast_timer / 0.5
		if _toast_timer <= 0:
			toast.visible = false
