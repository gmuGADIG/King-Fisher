extends Label3D
func _process(_delta: float) -> void:
	if(get_node("/root/Multiplayer").player_list.has(get_multiplayer_authority())): #Do not try updating the dict with new players until they offically get recorded
		text = str(get_node("/root/Multiplayer").player_list[get_multiplayer_authority()])
