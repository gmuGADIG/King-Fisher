extends CanvasLayer
#@export var sequence_visual_length:float
@onready var sequence_line: Line2D = $SequenceLine
@onready var sequence_line_length = (sequence_line.points[1]-sequence_line.points[0]).length()
@onready var player_line: Line2D = $PlayerLine
@onready var player_line_length = (player_line.points[1]-player_line.points[0]).length()

@onready var rhythm_engine: RhythmEngine = $rhythm_engine
@onready var indicator: Sprite2D = $PlayerLine/Indicator
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

var taps:Array[float] 
var tap_type:int

@export_category("Test")
@export var hit_sfx : AudioStream
@export var hit_sfx_art : AudioStream

const TRACK_LENGTH:int = 8
# Called when the node enters the scene tree for the first time.

var current_note_index : int = 0 
var current_note:Note

enum{
	NON_ARTICULATED,
	ARTICULATED
}

func _ready() -> void:
	place_ticks_sequence_line()
	place_ticks_player_line()
	indicator.position = Vector2(0,0)
	populate_sequence(track)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	indicator.position.x = ms_to_position(rhythm_engine.current_time_ms)
	#print(current_note_index)
	if current_note_index < track.notes.size():
		current_note = track.notes[current_note_index]
		if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(current_note.beat_position):
			$AudioStreamPlayer.stream = hit_sfx_art if current_note.is_articulated else hit_sfx
			$AudioStreamPlayer.play()
			current_note_index += 1
			 
			print("yay")
	if Input.is_action_just_pressed("catch_fish_main") or Input.is_action_just_pressed("catch_fish_secondary"):
		if Input.is_action_just_pressed("catch_fish_main"):
			tap_type = NON_ARTICULATED
			add_tap_marker(NON_ARTICULATED)
			determine_accuracy(NON_ARTICULATED)
		else:
			tap_type = ARTICULATED
			add_tap_marker(ARTICULATED)
			determine_accuracy(ARTICULATED)
		
		#taps.append(rhythm_engine.ms_to_beat(rhythm_engine.current_time_ms))
		#print(taps)
	
func determine_accuracy(tap_type: int) -> float:
	var note_position_ms : float = rhythm_engine.beat_to_ms(current_note.beat_position)
	var current_time : float = rhythm_engine.current_time_ms
	
	var difference : float = note_position_ms - current_time
	
	if (difference > hit_window_radius_ms):
		print("Early!")
		return 0
	elif (difference < -hit_window_radius_ms):
		print("Late!")
		return 0
	else:
		print("Hit!")
		if (note_is_tap_type(current_note, tap_type)):
			print("Match!")
		else:
			return 0
		if (abs(difference) < perfect_window_radius_ms):
			print("Perfect!")
			return perfect_hit_score
		else:
			print("OK!")
			return good_hit_score
	
	current_note_index += 1
	
	return 0

func note_is_tap_type(note: Note, beat_type: int) -> bool:	
	return note.is_articulated == (beat_type == ARTICULATED)

func place_ticks_sequence_line() -> void:
	var spacing = sequence_line_length/8
	for i in TRACK_LENGTH+1:
		var new_tick = Sprite2D.new()
		new_tick.texture = tick_sprite
		new_tick.position.y = sequence_line.points[0].y
		new_tick.position.x = sequence_line.points[0].x + spacing * i
		new_tick.scale = Vector2(tick_scale,tick_scale)
		sequence_line.add_child(new_tick)
		
func place_ticks_player_line() -> void:
	var spacing = player_line_length/8
	for i in TRACK_LENGTH+1:
		var new_tick = Sprite2D.new()
		new_tick.texture = tick_sprite
		new_tick.position.y = player_line.points[0].y
		new_tick.position.x = player_line.points[0].x + spacing * i
		new_tick.scale = Vector2(tick_scale,tick_scale)
		player_line.add_child(new_tick)

func populate_sequence(input_track:Track):
	print("input track:",input_track.notes.size())
	var spacing = sequence_line_length/8
	for i in input_track.notes:
		print("i'm a note")
		var new_note_marker = Sprite2D.new()
		new_note_marker.texture = note_marker_sprite if !i.is_articulated else note_marker_articulated_sprite
		new_note_marker.position.y = sequence_line.points[0].y
		new_note_marker.position.x = sequence_line.points[0].x + spacing * (i.beat_position - 1)
		new_note_marker.scale = Vector2(note_marker_scale,note_marker_scale) if !i.is_articulated else Vector2(note_marker_articulated_scale,note_marker_articulated_scale)
		sequence_line.add_child(new_note_marker)
		
func add_tap_marker(note_type:int) -> void:
	var new_tap_marker = Sprite2D.new()
	var spacing = player_line_length/8
	if note_type == 0:
		new_tap_marker.texture = tap_marker_sprite
		new_tap_marker.scale = Vector2(tap_marker_scale,tap_marker_scale)
	elif note_type == 1:
		new_tap_marker.texture = tap_marker_articulated_sprite
		new_tap_marker.scale = Vector2(tap_marker_articulated_scale,tap_marker_articulated_scale)
	new_tap_marker.position = indicator.position
	
	player_line.add_child(new_tap_marker)
func ms_to_position(ms:float) -> float:
	var position
	var total_ms = rhythm_engine.beat_to_ms(TRACK_LENGTH + 1)
	position = (ms * sequence_line_length)/total_ms
	return position
