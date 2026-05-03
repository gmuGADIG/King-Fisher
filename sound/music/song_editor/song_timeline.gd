extends Control
class_name SongTimeline

## A visual timeline control for song editing with draggable loop markers.
## Features:
## - Draggable loop start/end handles
## - Visual crossfade zone
## - Playhead indicator
## - Click to seek
## - Arrow keys for fine-tuning selected marker

signal loop_start_changed(value: float)
signal loop_end_changed(value: float)
signal seek_requested(position: float)
signal marker_selected(marker: String)  # "start", "end", or ""

# Constants
const HANDLE_WIDTH: float = 12.0
const HANDLE_HEIGHT: float = 32.0
const TRACK_HEIGHT: float = 48.0
const PLAYHEAD_WIDTH: float = 3.0
const FINE_STEP: float = 0.01  # Arrow key step in seconds
const COARSE_STEP: float = 0.1  # Shift+Arrow step

# Colors (modern dark theme)
const COLOR_TRACK_BG := Color(0.12, 0.12, 0.14, 1.0)
const COLOR_TRACK_PLAYED := Color(0.25, 0.25, 0.28, 1.0)
const COLOR_LOOP_REGION := Color(0.2, 0.5, 0.3, 0.3)
const COLOR_CROSSFADE_ZONE := Color(0.6, 0.4, 0.2, 0.4)
const COLOR_HANDLE_START := Color(0.3, 0.7, 0.4, 1.0)
const COLOR_HANDLE_END := Color(0.7, 0.4, 0.3, 1.0)
const COLOR_HANDLE_SELECTED := Color(1.0, 0.9, 0.5, 1.0)
const COLOR_PLAYHEAD := Color(1.0, 1.0, 1.0, 0.9)
const COLOR_TIME_TEXT := Color(0.7, 0.7, 0.7, 1.0)

# State
var song_length: float = 0.0
var loop_start: float = 0.0
var loop_end: float = 0.0
var playhead_position: float = 0.0
var fade_period: float = 0.2

var _selected_marker: String = ""  # "start", "end", or ""
var _dragging_marker: String = ""
var _hovered_marker: String = ""

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(400, TRACK_HEIGHT + 40)

func _draw() -> void:
	var track_rect := _get_track_rect()
	
	# Draw track background
	draw_rect(track_rect, COLOR_TRACK_BG, true)
	draw_rect(track_rect, COLOR_TRACK_BG.lightened(0.2), false, 1.0)
	
	if song_length <= 0:
		_draw_empty_state(track_rect)
		return
	
	# Draw played region (up to playhead)
	var played_width: float = _time_to_x(playhead_position) - track_rect.position.x
	if played_width > 0:
		var played_rect := Rect2(track_rect.position, Vector2(played_width, track_rect.size.y))
		draw_rect(played_rect, COLOR_TRACK_PLAYED, true)
	
	# Draw loop region
	var loop_start_x: float = _time_to_x(loop_start)
	var loop_end_x: float = _time_to_x(loop_end)
	var loop_rect := Rect2(
		Vector2(loop_start_x, track_rect.position.y),
		Vector2(loop_end_x - loop_start_x, track_rect.size.y)
	)
	draw_rect(loop_rect, COLOR_LOOP_REGION, true)
	
	# Draw crossfade zone
	var fade_start_x: float = _time_to_x(loop_end - fade_period)
	var fade_rect := Rect2(
		Vector2(fade_start_x, track_rect.position.y),
		Vector2(loop_end_x - fade_start_x, track_rect.size.y)
	)
	draw_rect(fade_rect, COLOR_CROSSFADE_ZONE, true)
	
	# Draw loop markers (handles)
	_draw_handle(loop_start_x, "start")
	_draw_handle(loop_end_x, "end")
	
	# Draw playhead
	var playhead_x: float = _time_to_x(playhead_position)
	draw_rect(
		Rect2(playhead_x - PLAYHEAD_WIDTH * 0.5, track_rect.position.y - 4, PLAYHEAD_WIDTH, track_rect.size.y + 8),
		COLOR_PLAYHEAD,
		true
	)
	
	# Draw time labels
	_draw_time_labels(track_rect)

func _draw_empty_state(track_rect: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	var text := "Load a song to begin"
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	var text_pos := track_rect.get_center() - text_size * 0.5
	draw_string(font, Vector2(text_pos.x, track_rect.get_center().y + 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_TIME_TEXT)

func _draw_handle(x_pos: float, marker_type: String) -> void:
	var track_rect := _get_track_rect()
	var is_selected := _selected_marker == marker_type
	var is_hovered := _hovered_marker == marker_type
	var is_dragging := _dragging_marker == marker_type
	
	var base_color: Color
	if marker_type == "start":
		base_color = COLOR_HANDLE_START
	else:
		base_color = COLOR_HANDLE_END
	
	if is_selected or is_dragging:
		base_color = COLOR_HANDLE_SELECTED
	elif is_hovered:
		base_color = base_color.lightened(0.3)
	
	# Draw handle as a rounded rect with a line extending into the track
	var handle_top := track_rect.position.y - 6
	var handle_rect := Rect2(
		x_pos - HANDLE_WIDTH * 0.5,
		handle_top,
		HANDLE_WIDTH,
		HANDLE_HEIGHT
	)
	
	# Triangle pointer at bottom
	var points: PackedVector2Array = [
		Vector2(x_pos - HANDLE_WIDTH * 0.5, handle_top + HANDLE_HEIGHT - 8),
		Vector2(x_pos + HANDLE_WIDTH * 0.5, handle_top + HANDLE_HEIGHT - 8),
		Vector2(x_pos, handle_top + HANDLE_HEIGHT + 4)
	]
	
	draw_rect(handle_rect, base_color, true)
	draw_polygon(points, [base_color])
	
	# Draw marker label
	var font: Font = ThemeDB.fallback_font
	var label := "S" if marker_type == "start" else "E"
	draw_string(font, Vector2(x_pos - 4, handle_top + 14), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.BLACK)

func _draw_time_labels(track_rect: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	var y_pos: float = track_rect.end.y + 16
	
	# Current position
	var current_text := _format_time(playhead_position)
	draw_string(font, Vector2(track_rect.position.x, y_pos), current_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, COLOR_TIME_TEXT)
	
	# Total length
	var total_text := _format_time(song_length)
	var total_width := font.get_string_size(total_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	draw_string(font, Vector2(track_rect.end.x - total_width, y_pos), total_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, COLOR_TIME_TEXT)
	
	# Loop start time (above start handle)
	if song_length > 0:
		var start_text := _format_time(loop_start)
		var start_x := _time_to_x(loop_start)
		draw_string(font, Vector2(start_x - 20, track_rect.position.y - 14), start_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_HANDLE_START)
		
		# Loop end time (above end handle)
		var end_text := _format_time(loop_end)
		var end_x := _time_to_x(loop_end)
		draw_string(font, Vector2(end_x - 20, track_rect.position.y - 14), end_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_HANDLE_END)

func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	var ms := int((seconds - int(seconds)) * 100)
	return "%d:%02d.%02d" % [mins, secs, ms]

func _get_track_rect() -> Rect2:
	var padding := HANDLE_WIDTH
	return Rect2(
		Vector2(padding, 24),
		Vector2(size.x - padding * 2, TRACK_HEIGHT)
	)

func _time_to_x(time: float) -> float:
	var track_rect := _get_track_rect()
	if song_length <= 0:
		return track_rect.position.x
	var ratio := clampf(time / song_length, 0.0, 1.0)
	return track_rect.position.x + ratio * track_rect.size.x

func _x_to_time(x: float) -> float:
	var track_rect := _get_track_rect()
	if track_rect.size.x <= 0:
		return 0.0
	var ratio := clampf((x - track_rect.position.x) / track_rect.size.x, 0.0, 1.0)
	return ratio * song_length

func _get_marker_at_position(pos: Vector2) -> String:
	if song_length <= 0:
		return ""
	
	var start_x := _time_to_x(loop_start)
	var end_x := _time_to_x(loop_end)
	var track_rect := _get_track_rect()
	
	# Check end marker first (it should have priority when overlapping)
	var end_handle := Rect2(end_x - HANDLE_WIDTH, track_rect.position.y - 10, HANDLE_WIDTH * 2, HANDLE_HEIGHT + 20)
	if end_handle.has_point(pos):
		return "end"
	
	var start_handle := Rect2(start_x - HANDLE_WIDTH, track_rect.position.y - 10, HANDLE_WIDTH * 2, HANDLE_HEIGHT + 20)
	if start_handle.has_point(pos):
		return "start"
	
	return ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)
	elif event is InputEventKey:
		_handle_key_input(event as InputEventKey)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		var marker := _get_marker_at_position(event.position)
		if marker != "":
			_dragging_marker = marker
			_selected_marker = marker
			marker_selected.emit(marker)
			grab_focus()
		else:
			# Click on track to seek
			var track_rect := _get_track_rect()
			if track_rect.has_point(event.position):
				var time := _x_to_time(event.position.x)
				seek_requested.emit(time)
			_selected_marker = ""
			marker_selected.emit("")
		queue_redraw()
	else:
		_dragging_marker = ""
		queue_redraw()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# Update hover state
	var old_hovered := _hovered_marker
	_hovered_marker = _get_marker_at_position(event.position)
	
	if _hovered_marker != "":
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if old_hovered != _hovered_marker:
		queue_redraw()
	
	if _dragging_marker != "":
		var new_time := _x_to_time(event.position.x)
		new_time = clampf(new_time, 0.0, song_length)
		
		if _dragging_marker == "start":
			new_time = minf(new_time, loop_end - 0.1)  # Keep start before end
			loop_start = new_time
			loop_start_changed.emit(new_time)
		else:
			new_time = maxf(new_time, loop_start + 0.1)  # Keep end after start
			loop_end = new_time
			loop_end_changed.emit(new_time)
		
		queue_redraw()

func _handle_key_input(event: InputEventKey) -> void:
	if not event.pressed or _selected_marker == "":
		return
	
	var step := COARSE_STEP if event.shift_pressed else FINE_STEP
	var direction := 0.0
	
	match event.keycode:
		KEY_LEFT:
			direction = -1.0
		KEY_RIGHT:
			direction = 1.0
		KEY_ESCAPE:
			_selected_marker = ""
			marker_selected.emit("")
			queue_redraw()
			accept_event()
			return
		_:
			return
	
	accept_event()
	
	if _selected_marker == "start":
		var new_val := clampf(loop_start + direction * step, 0.0, loop_end - 0.1)
		loop_start = new_val
		loop_start_changed.emit(new_val)
	else:
		var new_val := clampf(loop_end + direction * step, loop_start + 0.1, song_length)
		loop_end = new_val
		loop_end_changed.emit(new_val)
	
	queue_redraw()

# Public API
func set_song_length(length: float) -> void:
	song_length = length
	queue_redraw()

func set_loop_start(value: float) -> void:
	loop_start = value
	queue_redraw()

func set_loop_end(value: float) -> void:
	loop_end = value
	queue_redraw()

func set_playhead_position(pos: float) -> void:
	playhead_position = pos
	queue_redraw()

func set_fade_period(period: float) -> void:
	fade_period = period
	queue_redraw()
