extends Label3D

func _process(_delta: float) -> void:
	text = str(get_multiplayer_authority())
