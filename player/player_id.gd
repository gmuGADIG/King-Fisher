extends Label3D

func _process(_delta: float) -> void:
	if Multiplayer.player_list.has(get_multiplayer_authority()):
		text = Multiplayer.player_list[get_multiplayer_authority()].playerName
	else:
		text = "Player "+str(get_multiplayer_authority())
