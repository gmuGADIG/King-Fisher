extends Node

func client_id() -> String:
	return str(multiplayer.get_unique_id()).lpad(10,"0")
	
func log(...args: Array) -> void:
	var output : String = "["+client_id()+"] "
	for s in args:
		output += str(s)
	print(output)

func print_players() -> void:
	print("["+client_id()+"] Detected Players:")
	for player_id in Multiplayer.player_list:
		print(player_id)
