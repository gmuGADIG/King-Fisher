extends Node

enum LogMode{
	ALL = 0,
	SERVER = 1,
	CLIENT = 2
}

const log_mode : LogMode = LogMode.SERVER

func client_id() -> String:
	return str(multiplayer.get_unique_id()).lpad(10,"0")
	
func log(...args: Array) -> void:
	var uid : int = multiplayer.get_unique_id()
	if log_mode == LogMode.SERVER && uid != 1:
		return
	if log_mode == LogMode.CLIENT && uid == 1:
		return
	
	var output : String = "["+client_id()+"] "
	for s in args:
		output += str(s)
	print(output)

func print_players() -> void:
	print("["+client_id()+"] Detected Players:")
	for player_id in Multiplayer.player_list:
		print(player_id)
