extends Node
class_name MusicPlayer

signal song_changed(new_song: Song)
signal transition_finished
signal fade_out_finished
signal song_finished
signal section_entered(section_name: String)
signal section_exited(section_name: String)
signal section_looped(section_name: String)

@export var bus_name: String = "Music"
@export var song_transition_curve: Curve

const FULL_DB: float = 0.0
const MUTE_DB: float = -64.0
const VOLUME_TRANSITION_TIME: float = 0.2
const DEFAULT_TRANSITION_TIME: float = 1.0
const DEFAULT_FADE_OUT_DURATION: float = 2.0
const PERCEIVED_CURVE_EXPONENT: float = 2.0

@onready var players: Array[AudioStreamPlayer] = [$AudioStreamPlayerA, $AudioStreamPlayerB]

var active_idx: int = 0
var current_song: Song
var _in_loop_crossfade: bool = false
var _loop_crossfade_section: Section = null
var _is_song_transition: bool = false
var _transition_time_elapsed: float = 0.0
var _current_transition_duration: float = 1.0
var _volume_tween: Tween
var _fade_out_tween: Tween
var _target_volume: float = 1.0
var _is_paused: bool = false
var _song_stack: Array[Dictionary] = []
var _bus_indices: Array[int] = []
var _amplify_effects: Array[AudioEffectAmplify] = []

# Section tracking
var _last_seek_position: float = 0.0
var _previous_sections: Array[Section] = []

func _ready() -> void:
	_setup_player_buses()
	for i in players.size():
		players[i].bus = _get_player_bus_name(i)
		players[i].volume_db = MUTE_DB

func _process(delta: float) -> void:
	if _is_paused:
		return
	if _is_song_transition:
		_handle_song_transition(delta)
	elif current_song:
		_update_section_signals()
		if current_song.sections.size() > 0 and (_any_playing() or _song_ended()):
			_handle_section_loops()
		elif current_song.sections.size() == 0 and _song_ended():
			song_finished.emit()
			current_song = null

# =============================================================================
# PUBLIC API
# =============================================================================

## Play a song, optionally starting at a specific position or section.
## If section_name is provided, starts at that section's start time.
func play_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME, section_name: String = "") -> void:
	_kill_tween(_fade_out_tween)
	
	if _is_song_transition or _in_loop_crossfade:
		_inactive().stop()
		_inactive().stream = null
		_in_loop_crossfade = false
		_loop_crossfade_section = null
		_is_song_transition = false
		_active().volume_db = FULL_DB
	
	current_song = song
	_previous_sections.clear()
	
	# If section name provided, start at that section
	var start_point := at_point
	if section_name != "" and song:
		var section := song.get_section(section_name)
		if section:
			start_point = section.section_start
	
	_last_seek_position = start_point
	
	if transition_time > 0.0 and _any_playing():
		_start_song_transition(song, start_point, transition_time)
	else:
		_reset_players()
		active_idx = 0
		var active := _active()
		active.stream = song.song_file if song else null
		active.volume_db = FULL_DB
		active.play(start_point)
		_set_player_amplify(active_idx, song)
		song_changed.emit(song)

## Play a song starting at a specific section
func play_song_at_section(song: Song, section_name: String, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	play_song(song, 0.0, transition_time, section_name)

func push_song(song: Song, at_point: float = 0.0, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	if current_song:
		_song_stack.push_back({"song": current_song, "position": get_position()})
	play_song(song, at_point, transition_time)

func pop_song(fade_out_time: float = DEFAULT_FADE_OUT_DURATION, delay: float = 0.0, fade_in_time: float = 0.0) -> void:
	if _song_stack.is_empty():
		if fade_out_time > 0:
			fade_out(fade_out_time)
		else:
			stop()
		return
	
	var previous: Dictionary = _song_stack.pop_back()
	_do_pop_sequence(previous["song"], previous["position"], fade_out_time, delay, fade_in_time)

func stop() -> void:
	_reset_players()

func fade_out(duration: float = DEFAULT_FADE_OUT_DURATION) -> void:
	_inactive().stop()
	_kill_tween(_fade_out_tween)
	_fade_out_tween = create_tween()
	_fade_out_tween.tween_property(_active(), "volume_db", MUTE_DB, duration)
	_fade_out_tween.finished.connect(_on_fade_out_finished)

func clear_stack() -> void:
	_song_stack.clear()

func get_stack_size() -> int:
	return _song_stack.size()

func peek_stack() -> Dictionary:
	return _song_stack.back() if not _song_stack.is_empty() else {}

func seek(position: float) -> void:
	if not current_song:
		return
	
	_last_seek_position = position
	
	# Cancel any in-progress loop crossfade since we're seeking
	if _in_loop_crossfade:
		_inactive().stop()
		_inactive().stream = null
		_in_loop_crossfade = false
		_loop_crossfade_section = null
		_active().volume_db = FULL_DB
	
	var active := _active()
	if _is_paused:
		active.stream_paused = false
		active.seek(position)
		active.stream_paused = true
	elif active.playing:
		active.seek(position)
	else:
		active.play(position)

## Transition to a named section with optional crossfade.
## The new section fades in BEFORE section_start, reaching full volume exactly at section_start.
## Uses the destination section's fade curves for the transition.
func goto_section(section_name: String, transition_time: float = DEFAULT_TRANSITION_TIME) -> void:
	if not current_song:
		return
	
	var section := current_song.get_section(section_name)
	if not section:
		push_warning("MusicPlayer: Section '%s' not found" % section_name)
		return
	
	var target_position := section.section_start
	_last_seek_position = target_position
	
	# Cancel any in-progress loop crossfade
	if _in_loop_crossfade:
		_inactive().stop()
		_inactive().stream = null
		_in_loop_crossfade = false
		_loop_crossfade_section = null
		_active().volume_db = FULL_DB
	
	if transition_time > 0.0 and _any_playing():
		# Start playback before section_start so we fade in and hit full volume at section_start
		var fade_in_start := maxf(0.0, target_position - transition_time)
		_start_section_transition(section, fade_in_start, transition_time)
	else:
		seek(target_position)

func pause() -> void:
	if _is_paused:
		return
	_is_paused = true
	for player in players:
		player.stream_paused = true

func resume() -> void:
	if not _is_paused:
		return
	_is_paused = false
	for player in players:
		player.stream_paused = false

func is_playing() -> bool:
	return not _is_paused and (_active().playing or _active().stream_paused)

func is_paused() -> bool:
	return _is_paused

func get_position() -> float:
	return _active().get_playback_position()

func get_length() -> float:
	var stream := _active().stream
	return stream.get_length() if stream else 0.0

func get_current_song() -> Song:
	return current_song

## Returns the current section(s) at the playback position (most specific first)
func get_current_sections() -> Array[Section]:
	return _get_sections_at_position(get_position())

## Returns the most specific (smallest) section at the current position, or null
func get_current_section() -> Section:
	var sections := get_current_sections()
	return sections[0] if sections.size() > 0 else null

func set_loudness(perceived_level: float, duration: float = 0.0) -> void:
	perceived_level = clampf(perceived_level, 0.0, 1.0)
	_target_volume = perceived_level
	var linear_level := pow(perceived_level, PERCEIVED_CURVE_EXPONENT)
	_apply_player_volume_db(linear_level, duration)

func set_volume(linear_level: float, duration: float = 0.0) -> void:
	# Legacy: linear amplitude 0..1
	linear_level = clampf(linear_level, 0.0, 1.0)
	_target_volume = pow(maxf(linear_level, 0.0), 1.0 / PERCEIVED_CURVE_EXPONENT)
	_apply_player_volume_db(linear_level, duration)

func set_master_loudness(perceived_level: float, duration: float = 0.0) -> void:
	perceived_level = clampf(perceived_level, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("MusicPlayer: Bus '%s' not found for master loudness" % bus_name)
		return
	
	var linear_level := pow(perceived_level, PERCEIVED_CURVE_EXPONENT)
	var target_db := MUTE_DB if linear_level == 0.0 else linear_to_db(linear_level)
	AudioServer.set_bus_volume_db(bus_idx, target_db)

func get_volume() -> float:
	return pow(_target_volume, PERCEIVED_CURVE_EXPONENT)

func get_loudness() -> float:
	return _target_volume

func get_master_loudness() -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return _target_volume
	var linear := db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return pow(linear, 1.0 / PERCEIVED_CURVE_EXPONENT)

func _apply_player_volume_db(linear_level: float, duration: float) -> void:
	var target_db := MUTE_DB if linear_level == 0.0 else linear_to_db(linear_level)
	_kill_tween(_volume_tween)
	if duration > 0.0:
		_volume_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		for player in players:
			_volume_tween.tween_property(player, "volume_db", target_db, duration)
	else:
		for player in players:
			player.volume_db = target_db

func refresh_amplify() -> void:
	_set_player_amplify(active_idx, current_song)

# =============================================================================
# INTERNAL
# =============================================================================

func _get_player_bus_name(idx: int) -> String:
	return "%s_%d" % [bus_name, idx]

func _setup_player_buses() -> void:
	var parent_idx := AudioServer.get_bus_index(bus_name)
	if parent_idx == -1:
		push_warning("MusicPlayer: Bus '%s' not found, creating it" % bus_name)
		parent_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(parent_idx, bus_name)
	
	for i in 2:
		var child_name := _get_player_bus_name(i)
		var child_idx := AudioServer.get_bus_index(child_name)
		
		if child_idx == -1:
			child_idx = AudioServer.bus_count
			AudioServer.add_bus(child_idx)
			AudioServer.set_bus_name(child_idx, child_name)
			AudioServer.set_bus_send(child_idx, bus_name)
			var effect := AudioEffectAmplify.new()
			effect.volume_db = 0.0
			AudioServer.add_bus_effect(child_idx, effect)
		
		_bus_indices.append(child_idx)
		for j in AudioServer.get_bus_effect_count(child_idx):
			var effect := AudioServer.get_bus_effect(child_idx, j)
			if effect is AudioEffectAmplify:
				_amplify_effects.append(effect)
				break

func _set_player_amplify(player_idx: int, song: Song) -> void:
	if player_idx < _amplify_effects.size():
		_amplify_effects[player_idx].volume_db = song.amplify_db if song else 0.0

func _start_song_transition(song: Song, at_point: float, duration: float) -> void:
	_is_song_transition = true
	_transition_time_elapsed = 0.0
	_current_transition_duration = duration
	var inactive_idx := 1 - active_idx
	var inactive := _inactive()
	inactive.stream = song.song_file if song else null
	inactive.volume_db = MUTE_DB
	_set_player_amplify(inactive_idx, song)
	inactive.play(at_point)

func _start_section_transition(section: Section, at_point: float, duration: float) -> void:
	# Similar to song transition but uses section's fade curves
	_is_song_transition = true
	_transition_time_elapsed = 0.0
	_current_transition_duration = duration
	var inactive_idx := 1 - active_idx
	var inactive := _inactive()
	inactive.stream = current_song.song_file
	inactive.volume_db = MUTE_DB
	_set_player_amplify(inactive_idx, current_song)
	inactive.play(at_point)

func _handle_song_transition(delta: float) -> void:
	_transition_time_elapsed += delta
	var t := minf(_transition_time_elapsed / _current_transition_duration, 1.0)
	var fade_in_amt := song_transition_curve.sample(t) if song_transition_curve else t
	var fade_out_amt := song_transition_curve.sample(1.0 - t) if song_transition_curve else (1.0 - t)
	
	_inactive().volume_db = MUTE_DB + (-MUTE_DB) * fade_in_amt
	_active().volume_db = MUTE_DB + (-MUTE_DB) * fade_out_amt
	
	if _transition_time_elapsed >= _current_transition_duration:
		_active().stop()
		_active().stream = null
		active_idx = 1 - active_idx
		_is_song_transition = false
		_active().volume_db = FULL_DB
		transition_finished.emit()
		song_changed.emit(current_song)

func _do_pop_sequence(song: Song, at_position: float, fade_out_time: float, delay: float, fade_in_time: float) -> void:
	# Update current_song immediately so that if push_song is called during
	# the fade-out, it will save the correct song (the one we're transitioning to)
	# rather than the one that's fading out.
	current_song = song
	
	if fade_out_time > 0 and _any_playing():
		_inactive().stop()
		_kill_tween(_fade_out_tween)
		_fade_out_tween = create_tween()
		_fade_out_tween.tween_property(_active(), "volume_db", MUTE_DB, fade_out_time)
		await _fade_out_tween.finished
		stop()
	else:
		stop()
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	if fade_in_time > 0:
		_reset_players()
		active_idx = 0
		var active := _active()
		current_song = song
		active.stream = song.song_file if song else null
		active.volume_db = MUTE_DB
		active.play(at_position)
		_set_player_amplify(active_idx, song)
		_last_seek_position = at_position
		var tween := create_tween()
		tween.tween_property(active, "volume_db", FULL_DB, fade_in_time)
		await tween.finished
		song_changed.emit(song)
	else:
		play_song(song, at_position, 0.0)

func _on_fade_out_finished() -> void:
	fade_out_finished.emit()
	stop()

## Get all sections containing the given position, sorted by size (smallest first)
func _get_sections_at_position(pos: float) -> Array[Section]:
	var result: Array[Section] = []
	if not current_song:
		return result
	
	for section in current_song.sections:
		if section.section_start <= pos and pos < section.section_end:
			result.append(section)
	
	# Sort by section size (smallest/most specific first)
	result.sort_custom(func(a: Section, b: Section) -> bool:
		return a.get_duration() < b.get_duration()
	)
	
	return result

## Check if we're eligible to loop in a section based on _last_seek_position
func _can_loop_in_section(section: Section) -> bool:
	return section.loop and _last_seek_position <= section.section_end

## Update section enter/exit signals
func _update_section_signals() -> void:
	if not current_song or current_song.sections.size() == 0:
		return
	
	var pos := get_position()
	var current_sections := _get_sections_at_position(pos)
	
	# Find exited sections
	for prev_section in _previous_sections:
		var still_in := false
		for curr_section in current_sections:
			if curr_section == prev_section:
				still_in = true
				break
		if not still_in:
			section_exited.emit(prev_section.section_name)
	
	# Find entered sections
	for curr_section in current_sections:
		var was_in := false
		for prev_section in _previous_sections:
			if prev_section == curr_section:
				was_in = true
				break
		if not was_in:
			section_entered.emit(curr_section.section_name)
	
	_previous_sections = current_sections

## Handle looping for sections
func _handle_section_loops() -> void:
	var active := _active()
	var inactive := _inactive()
	var pos := active.get_playback_position()
	var song_length := active.stream.get_length() if active.stream else 0.0
	
	# Check each looping section
	for section in current_song.sections:
		if not section.loop:
			continue
		if not _can_loop_in_section(section):
			continue
		
		var inside := section.section_start <= pos and pos < section.section_end
		var fade_period := section.fade_period
		var fade_start := section.section_end - fade_period
		var new_loop_start := maxf(0.0, section.section_start - fade_period)
		
		# Simple loop (no crossfade) when fade is negligible and section ends at track end
		if inside and fade_period < 0.01 and song_length > 0 and section.section_end >= song_length - 0.1:
			if pos >= section.section_end - 0.05:
				active.play(section.section_start)
				section_looped.emit(section.section_name)
			return
		
		# Start crossfade when inside section and near the end
		if inside and pos >= fade_start and _loop_crossfade_section == null:
			_in_loop_crossfade = true
			_loop_crossfade_section = section
			inactive.stream = current_song.song_file
			inactive.volume_db = MUTE_DB
			_set_player_amplify(1 - active_idx, current_song)
			inactive.play(new_loop_start)
		
		# Apply crossfade volumes
		if _in_loop_crossfade and _loop_crossfade_section == section:
			# If active player stopped (audio ended during crossfade), complete the loop immediately
			if not active.playing:
				active.stream = null
				active_idx = 1 - active_idx
				_in_loop_crossfade = false
				_loop_crossfade_section = null
				_active().volume_db = FULL_DB
				_inactive().volume_db = MUTE_DB
				section_looped.emit(section.section_name)
				return
			
			var t := clampf((pos - fade_start) / fade_period, 0.0, 1.0)
			var out_amp := sqrt(maxf(0.0, section.fade_out_curve.sample(t))) if section.fade_out_curve else (1.0 - t)
			var in_amp := sqrt(maxf(0.0, section.fade_in_curve.sample(t))) if section.fade_in_curve else t
			active.volume_db = linear_to_db(out_amp) if out_amp > 0.0001 else MUTE_DB
			inactive.volume_db = linear_to_db(in_amp) if in_amp > 0.0001 else MUTE_DB
		
		# Complete loop when we reach or pass section end
		if pos >= section.section_end:
			# If we were crossfading in a different section, skip
			if _loop_crossfade_section != null and _loop_crossfade_section != section:
				continue
			
			if not _in_loop_crossfade:
				# Edge case: reached end without starting crossfade (missed window or no fade)
				inactive.stream = current_song.song_file
				inactive.volume_db = FULL_DB
				_set_player_amplify(1 - active_idx, current_song)
				inactive.play(section.section_start)
			active.stop()
			active.stream = null
			active_idx = 1 - active_idx
			_in_loop_crossfade = false
			_loop_crossfade_section = null
			_active().volume_db = FULL_DB
			_inactive().volume_db = MUTE_DB
			section_looped.emit(section.section_name)
			return
	
	# No looping sections triggered - check if song ended
	if _song_ended() and not _in_loop_crossfade:
		# Check if we should loop (audio ended before section_end)
		var final_pos := _active().get_playback_position()
		for section in current_song.sections:
			if not section.loop:
				continue
			if not _can_loop_in_section(section):
				continue
			# If audio ended while inside or near the section, loop back
			if final_pos >= section.section_start:
				inactive.stream = current_song.song_file
				inactive.volume_db = FULL_DB
				_set_player_amplify(1 - active_idx, current_song)
				inactive.play(section.section_start)
				_active().stop()
				_active().stream = null
				active_idx = 1 - active_idx
				_inactive().volume_db = MUTE_DB
				section_looped.emit(section.section_name)
				return
		
		song_finished.emit()
		current_song = null

func _reset_players() -> void:
	for player in players:
		player.stop()
		player.stream = null
		player.volume_db = MUTE_DB
		player.stream_paused = false
	_in_loop_crossfade = false
	_loop_crossfade_section = null
	_is_song_transition = false
	_is_paused = false
	_previous_sections.clear()

func _kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()

func _active() -> AudioStreamPlayer:
	return players[active_idx]

func _inactive() -> AudioStreamPlayer:
	return players[1 - active_idx]

func _any_playing() -> bool:
	return players[0].playing or players[1].playing

func _song_ended() -> bool:
	var active := _active()
	return active.stream != null and not active.playing
