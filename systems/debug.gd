extends Node

enum LogMode{
	ALL = 0,
	SERVER = 1,
	CLIENT = 2
}

@export var log_mode : LogMode = LogMode.ALL
@export var disable_backing_track : bool = false
@export var mute_songs : bool = false

func _ready() -> void:
	Options.music_volume = 0.0

func client_id() -> String:
	if multiplayer.multiplayer_peer == null:
		return str(1).lpad(10,"0")
	return str(multiplayer.get_unique_id()).lpad(10,"0")

func create_debug_string(args: Array) -> String:
	var output : String = "["+client_id()+"] "

	# get caller
	if OS.is_debug_build():
		# 0 = us
		# 1 = caller
		var caller: Dictionary = get_stack()[2]
		var source_file: String = caller.source
		source_file = source_file.split('/')[-1]
		output += ("[%s:%d]" % [source_file, caller.line])
	
	output = output.rpad(35, ' ')

	for s in args:
		output += str(s)
	return output

func log_mode_enabled() -> bool:
	var uid : int = 1
	if multiplayer.multiplayer_peer != null:
		uid = multiplayer.get_unique_id()
	if log_mode == LogMode.SERVER && uid != 1:
		return false
	if log_mode == LogMode.CLIENT && uid == 1:
		return false
	return true

func log(...args: Array) -> void:
	if not log_mode_enabled():
		return
	print(create_debug_string(args))

func log_err(... args: Array) -> void:
	push_error(create_debug_string(args))


func print_players() -> void:
	print("["+client_id()+"] Detected Players:")
	for player_id in Multiplayer.player_list:
		print(player_id)
