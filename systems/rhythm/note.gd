class_name Note extends Resource

##When the player is supposed to press the input. 1 beat = 1 quarter note
@export var beat_position: float
##If selected, the player will need to hit the articulation button instead
@export var is_articulated: bool



func _init(_beat_position: float = 0, _is_articulated: bool = false) -> void:
	beat_position = _beat_position
	is_articulated = _is_articulated
