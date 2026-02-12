class_name Note extends Resource

@export var beat_position: float
@export var is_articulated: bool

func _init(_beat_position: float, _is_articulated: bool = false) -> void:
	beat_position = _beat_position
	is_articulated = _is_articulated
