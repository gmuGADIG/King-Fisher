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

	# get caller
	if OS.is_debug_build():
		# 0 = us
		# 1 = caller
		var caller: Dictionary = get_stack()[1]
		var source_file: String = caller.source
		source_file = source_file.split('/')[-1]
		output += ("[%s:%d]" % [source_file, caller.line])
	
	output = output.rpad(35, ' ')

	for s in args:
		output += str(s)
	print(output)

func print_players() -> void:
	print("["+client_id()+"] Detected Players:")
	for player_id in Multiplayer.player_list:
		print(player_id)
