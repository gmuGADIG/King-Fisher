extends CanvasLayer

const TRACK_LENGTH:int = 8

enum NoteType{
	NON_ARTICULATED,
	ARTICULATED
}

enum Phase{
	FISH_CALL,
	PLAYER_RESPONSE,
	MINIGAME_FINISH
}

enum HitQuality{
	MISS,
	GOOD,
	PERFECT
}

@export var track:Track
@export var tick_sprite:CompressedTexture2D
@export var note_marker_sprite:CompressedTexture2D
@export var note_marker_articulated_sprite:CompressedTexture2D
@export var tap_marker_sprite:CompressedTexture2D
@export var tap_marker_articulated_sprite:CompressedTexture2D
@export var tick_scale:float = 1.0
@export var note_marker_scale:float = 1.0
@export var note_marker_articulated_scale:float = 1.0
@export var tap_marker_articulated_scale:float = 1.0
@export var tap_marker_scale:float = 1.0

@export var good_hit_score:float = 0.7
@export var perfect_hit_score:float = 1.0
@export var hit_window_radius_ms:float = 500.0
@export var perfect_window_radius_ms:float = 100.0

@export_category("Test")
@export var hit_sfx : AudioStream
@export var hit_sfx_art : AudioStream

#var score:float = 0
var perfect_hits:int = 0
var good_hits:int = 0
var misses:int = 0


# Called when the node enters the scene tree for the first time.

var call_index:int = 0
var response_index : int = 0 
var current_note:Note

var state : Phase = Phase.FISH_CALL


@onready var sequence_line: Line2D = $SequenceLine
@onready var sequence_line_length = (sequence_line.points[1]-sequence_line.points[0]).length()
@onready var player_line: Line2D = $PlayerLine
@onready var player_line_length : float = (player_line.points[1]-player_line.points[0]).length()
@onready var win_lose_sprite: Sprite2D = $WinLose


@onready var rhythm_engine: RhythmEngine = $rhythm_engine
@onready var player_indicator: Sprite2D = $PlayerLine/PlayerIndicator
@onready var fish_indicator: Sprite2D = $SequenceLine/FishIndicator
@onready var main_audio_stream: AudioStreamPlayer = $MainAudioStream

func _ready() -> void:
	place_ticks(player_line)
	place_ticks(sequence_line)
	player_indicator.position = Vector2(0,0)
	fish_indicator.position = Vector2(0,0)
	populate_sequence(track)
	rhythm_engine.play(track)
	win_lose_sprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms))
	#print(ms_to_position())
	#print(int(rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms)))
	#print("target ms: ",rhythm_engine.beat_to_ms(track.notes[current_note_index].beat_position), ", current ms: ",rhythm_engine.current_time_ms)
	## Update Indicator
	
	fish_indicator.position.x = ms_to_position(rhythm_engine.current_time_ms)
	player_indicator.position.x = ms_to_position(rhythm_engine.current_time_ms-rhythm_engine.beat_to_ms(8))

	
	
	##Call:
	if (call_index < track.notes.size()):
		var current_note_sfx = track.notes[call_index]
		if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(current_note_sfx.beat_position):
			main_audio_stream.stream = hit_sfx_art if current_note_sfx.is_articulated else hit_sfx
			main_audio_stream.play()
			call_index +=1
	
	if state == Phase.FISH_CALL:
		if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= TRACK_LENGTH:
			state = Phase.PLAYER_RESPONSE
	
	##Response
	if state == Phase.PLAYER_RESPONSE and response_index < track.notes.size():
		current_note = track.notes[response_index]
		##HACK: there's an off by one here to actually get it to be on the line, there's likely something going on elsewhere in the code
		if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(current_note.beat_position+TRACK_LENGTH+1) + hit_window_radius_ms:
			response_index+=1
			print("Miss!")
			misses+=1
	
	if state == Phase.PLAYER_RESPONSE:
		if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= 2*TRACK_LENGTH:
			print("perfect: " + str(perfect_hits) + " good: " + str(good_hits) + " misses: " + str(misses))
			state = Phase.MINIGAME_FINISH
			
	#match state:
		#Phase.FISH_CALL:
			###Call Audio Playback
			#
			#pass
			###Transition to response
			#if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= TRACK_LENGTH+1:
				#state = Phase.PLAYER_RESPONSE
				#rhythm_engine.current_time_ms -= rhythm_engine.beat_to_ms(TRACK_LENGTH)
		#Phase.PLAYER_RESPONSE:
			#
			### Miss if no input pressed in the time window
			#if current_note_index < track.notes.size():
				#current_note = track.notes[current_note_index]
				###HACK: there's an off by one here to actually get it to be on the line, there's likely something going on elsewhere in the code
				#if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(current_note.beat_position) + hit_window_radius_ms:
					#current_note_index+=1
					#print("Miss!")
					#misses+=1
			#
			#if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= TRACK_LENGTH + 1:
				#print("perfect: " + str(perfect_hits) + " good: " + str(good_hits) + " misses: " + str(misses))
				#print("score:", score)
				#print("taps:", total_taps)
				#total_accuracy = score / total_taps	
				#print("accuracy:", total_accuracy)
				#if total_accuracy >= track.target_accuracy * .01:
					#print("WIN!")
					#win_lose_sprite.frame = 0
					#win_lose_sprite.visible = true
				#else:
					#print("LOSE!")
					#win_lose_sprite.frame = 1
					#win_lose_sprite.visible = true
				#
				#state=Phase.MINIGAME_FINISH
				#
		#Phase.MINIGAME_FINISH:
			#pass
		#taps.append(rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms))
		#print(taps)

func _input(event: InputEvent) -> void:
	if state == Phase.PLAYER_RESPONSE:
		if response_index >= track.notes.size():
			return
		
		var input_type : NoteType
		if event.is_action_pressed("catch_fish_main"):
			input_type = NoteType.NON_ARTICULATED
		elif event.is_action_pressed("catch_fish_secondary"):
			input_type = NoteType.ARTICULATED
		else: ##Not a note in the thing
			return
		
		main_audio_stream.stream = hit_sfx_art if input_type == NoteType.ARTICULATED else hit_sfx
		main_audio_stream.play()
		
		var hit_quality : HitQuality = determine_accuracy()
		
		var expected_note_type : NoteType = NoteType.ARTICULATED if track.notes[response_index].is_articulated else NoteType.NON_ARTICULATED
		print(hit_quality)
		if expected_note_type != input_type or hit_quality == HitQuality.MISS:
			print("miss :(")
			misses += 1
		elif hit_quality == HitQuality.GOOD:
			print("Good")
			#score += good_hit_score
			good_hits += 1
			response_index += 1
		elif hit_quality == HitQuality.PERFECT:
			print("Perfect!")
			#score += perfect_hit_score
			perfect_hits += 1
			response_index += 1
		else:
			assert(false, "Edge case detected")
		
		## Draw marker to screen
		add_tap_marker(input_type)
		
		
		#if event.is_action_pressed("catch_fish_main"):
			#tap_type = NoteType.NON_ARTICULATED
			#add_tap_marker(NoteType.NON_ARTICULATED)
			#if current_note_index < track.notes.size():
				#score += determine_accuracy(NoteType.NON_ARTICULATED)
		#elif 
			#tap_type = NoteType.ARTICULATED
			#add_tap_marker(NoteType.ARTICULATED)
			#if current_note_index < track.notes.size():
				#score += determine_accuracy(NoteType.ARTICULATED)
			#print("score:", score)


func determine_accuracy() -> HitQuality:
	print(response_index)
	##HACK: there's an off by one here to actually get it to be on the line, there's likely something going on elsewhere in the code
	current_note = track.notes[response_index]
	print("input: ",rhythm_engine.beat_to_ms(current_note.beat_position))
	var note_position_ms : float = rhythm_engine.beat_to_ms(current_note.beat_position+TRACK_LENGTH)
	var current_time : float = rhythm_engine.current_time_ms
	
	var difference : float = note_position_ms - current_time
	print("diff: ",difference)
	if (difference > hit_window_radius_ms):
		return HitQuality.MISS
	elif (difference < -hit_window_radius_ms):
		return HitQuality.MISS
	
	var distance : float = absf(difference)
	
	if distance < perfect_window_radius_ms:
		return HitQuality.PERFECT
	else:
		return HitQuality.GOOD

func note_is_tap_type(note: Note, beat_type: NoteType) -> bool:	
	return note.is_articulated == (beat_type == NoteType.ARTICULATED)

func place_ticks(line : Line2D) -> void:
	var line_length : float = absf(line.points[1].x-line.points[0].x)
	var spacing = line_length/(TRACK_LENGTH)
	
	for i in TRACK_LENGTH+1:
		var new_tick = Sprite2D.new()
		new_tick.texture = tick_sprite
		new_tick.position.y = line.points[0].y
		new_tick.position.x = line.points[0].x + spacing * i
		new_tick.scale = Vector2(tick_scale,tick_scale)
		line.add_child(new_tick)

func populate_sequence(input_track:Track):
	print("input track:",input_track.notes.size())
	var spacing = sequence_line_length/(TRACK_LENGTH)
	for i in input_track.notes:
		print("i'm a note")
		var new_note_marker = Sprite2D.new()
		new_note_marker.texture = note_marker_sprite if !i.is_articulated else note_marker_articulated_sprite
		new_note_marker.position.y = sequence_line.points[0].y
		new_note_marker.position.x = sequence_line.points[0].x + spacing * (i.beat_position - 1)
		new_note_marker.scale = Vector2(note_marker_scale,note_marker_scale) if !i.is_articulated else Vector2(note_marker_articulated_scale,note_marker_articulated_scale)
		sequence_line.add_child(new_note_marker)
		
func add_tap_marker(note_type : NoteType) -> void:
	var new_tap_marker = Sprite2D.new()
	var spacing = player_line_length/(TRACK_LENGTH+1)
	if note_type == NoteType.NON_ARTICULATED:
		new_tap_marker.texture = tap_marker_sprite
		new_tap_marker.scale = Vector2(tap_marker_scale,tap_marker_scale)
	elif note_type == NoteType.ARTICULATED:
		new_tap_marker.texture = tap_marker_articulated_sprite
		new_tap_marker.scale = Vector2(tap_marker_articulated_scale,tap_marker_articulated_scale)
	new_tap_marker.position = player_indicator.position
	player_line.add_child(new_tap_marker)
	
func calculate_total_accuracy() -> void:
	pass

func ms_to_position(ms:float) -> float:
	
	var spacing : float = player_line_length/(TRACK_LENGTH)
	var position : float = (rhythm_engine.ms_to_beat(ms)-1) * spacing
	return position
