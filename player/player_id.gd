extends Label3D
func _process(_delta: float) -> void:
	var multi_authority : int = get_multiplayer_authority()
	if Multiplayer.player_list.has(multi_authority): #Do not try updating the dict with new players until they offically get recorded
		text = str(Multiplayer.player_list[multi_authority])
