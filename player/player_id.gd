extends Label3D
func _process(_delta: float) -> void:
	text = str(get_node("/root/Multiplayer").player_list[get_multiplayer_authority()])
	#text = str(get_node("/root/Multiplayer").player_list[multiplayer.multiplayer_peer.get_unique_id()])
