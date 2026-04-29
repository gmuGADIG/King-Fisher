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
@export var tick_marker : PackedScene
@export var note_marker : PackedScene
@export var note_articulated_marker : PackedScene


@export_range(0.0,1.0,0.01) var good_hit_accuracy:float = 0.7
const perfect_hit_accuracy : float = 1.0
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
	##Uncomment this when the actual backing UI is done
	$PlayerLine.default_color.a = 0
	$SequenceLine.default_color.a = 0
	place_ticks(player_line)
	place_ticks(sequence_line)
	player_indicator.position = Vector2(0,0)
	player_indicator.hide()
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
		if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= TRACK_LENGTH+0.5:
			state = Phase.PLAYER_RESPONSE
			player_indicator.show()
			fish_indicator.hide()
	
	##Response
	if state == Phase.PLAYER_RESPONSE and response_index < track.notes.size():
		current_note = track.notes[response_index]
		##HACK: there's an off by one here to actually get it to be on the line, there's likely something going on elsewhere in the code
		if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(current_note.beat_position+TRACK_LENGTH) + hit_window_radius_ms:
			response_index+=1
			print("Miss!")
			misses+=1
	
	if state == Phase.PLAYER_RESPONSE:
		if rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms) >= 2*TRACK_LENGTH:
			player_indicator.hide()
			##Percentage accuracy from 0 to 1
			var accuracy : float = calculate_accuracy()
			$ScoreLabel.text = str("%.2f" % (accuracy*100.0)) + "%"
			print("perfect: " + str(perfect_hits) + " good: " + str(good_hits) + " misses: " + str(misses))
			state = Phase.MINIGAME_FINISH

func calculate_accuracy() -> float:
	var presses : int = misses+good_hits+perfect_hits
	var accuracy : float = (good_hit_accuracy * good_hits + perfect_hit_accuracy * perfect_hits)/presses
	return accuracy

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
	var spacing = line_length/(TRACK_LENGTH*2-2)
	
	for i in range(-1,TRACK_LENGTH*2):
		var new_tick : Sprite2D = tick_marker.instantiate()
		new_tick.position.y = line.points[0].y
		new_tick.position.x = line.points[0].x + spacing * i
		#new_tick.scale = Vector2(tick_scale,tick_scale)
		if i%2 == 0:
			new_tick.scale *= 1.25
		line.add_child(new_tick)

func populate_sequence(input_track:Track):
	print("input track:",input_track.notes.size())
	var spacing = sequence_line_length/(TRACK_LENGTH-1)
	for note in input_track.notes:
		print("i'm a note")
		var new_note_marker : Sprite2D
		if note.is_articulated:
			new_note_marker = note_articulated_marker.instantiate()
		else:
			new_note_marker = note_marker.instantiate()
		
		new_note_marker.position.y = sequence_line.points[0].y
		new_note_marker.position.x = sequence_line.points[0].x + spacing * (note.beat_position - 1)
		sequence_line.add_child(new_note_marker)
		
func add_tap_marker(note_type : NoteType) -> void:
	
	var spacing = player_line_length/(TRACK_LENGTH)
	var new_note_marker : Sprite2D
	if note_type == NoteType.ARTICULATED:
		new_note_marker = note_articulated_marker.instantiate()
	else:
		new_note_marker = note_marker.instantiate()
	new_note_marker.position = player_indicator.position
	player_line.add_child(new_note_marker)
	
func calculate_total_accuracy() -> void:
	pass

func ms_to_position(ms:float) -> float:
	
	var spacing : float = player_line_length/(TRACK_LENGTH-1)
	var position : float = (rhythm_engine.ms_to_beat(ms)-1) * spacing
	return position
