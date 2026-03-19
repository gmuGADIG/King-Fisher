extends CanvasLayer
#@export var sequence_visual_length:float
@onready var sequence_line: Line2D = $SequenceLine
@onready var sequence_line_length = (sequence_line.points[1]-sequence_line.points[0]).length()
@onready var rhythm_engine: RhythmEngine = $rhythm_engine
@onready var indicator: Sprite2D = $SequenceLine/Indicator
@export var track:Track
@export var tick_sprite:CompressedTexture2D
@export var note_marker_sprite:CompressedTexture2D
@export var tick_scale:float = 1.0
@export var note_marker_scale:float = 1.0

@export_category("Test")
@export var hit_sfx : AudioStream
@export var hit_sfx_art : AudioStream

const TRACK_LENGTH:int = 8
# Called when the node enters the scene tree for the first time.

var current_note_index : int = 0

func _ready() -> void:
	place_ticks()
	indicator.position = Vector2(0,0)
	populate_sequence(track)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	indicator.position.x = ms_to_position(rhythm_engine.current_time_ms)
	#print(current_note_index)
	if current_note_index < track.notes.size():
		if rhythm_engine.current_time_ms >= rhythm_engine.beat_to_ms(track.notes[current_note_index].beat_position):
			$AudioStreamPlayer.stream = hit_sfx_art if track.notes[current_note_index].is_articulated else hit_sfx
			$AudioStreamPlayer.play()
			current_note_index += 1
			
			print("yay")
	
func place_ticks() -> void:
	var spacing = sequence_line_length/8
	for i in TRACK_LENGTH+1:
		var new_tick = Sprite2D.new()
		new_tick.texture = tick_sprite
		new_tick.position.y = sequence_line.points[0].y
		new_tick.position.x = sequence_line.points[0].x + spacing * i
		new_tick.scale = Vector2(tick_scale,tick_scale)
		sequence_line.add_child(new_tick)

func populate_sequence(input_track:Track):
	print("input track:",input_track.notes.size())
	var spacing = sequence_line_length/8
	for i in input_track.notes:
		print("i'm a note")
		var new_note_marker = Sprite2D.new()
		new_note_marker.texture = note_marker_sprite
		new_note_marker.position.y = sequence_line.points[0].y
		new_note_marker.position.x = sequence_line.points[0].x + spacing * i.beat_position
		new_note_marker.scale = Vector2(note_marker_scale,note_marker_scale)
		sequence_line.add_child(new_note_marker)
		
func ms_to_position(ms:float) -> float:
	var position
	var total_ms = rhythm_engine.beat_to_ms(TRACK_LENGTH)
	position = (ms * sequence_line_length)/total_ms
	return position
