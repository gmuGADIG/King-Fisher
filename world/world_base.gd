class_name WorldBase
extends Node3D

static var returning_to_lobby : bool = false

@export var player : PackedScene

func _ready() -> void:
	UIState.ui_state = UIState.State.NONE
	# TODO: do this without looking at the name
	if name != "Lobby":
		Multiplayer.report_loaded.rpc()
		if not multiplayer.is_server():
			spawn_request.rpc_id(1)
	else:
		Multiplayer.status = ""
	
	if returning_to_lobby:
		spawn_request.rpc_id(1)
		Multiplayer.set_ready.rpc(false)
		returning_to_lobby = false
	
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		Debug.log("Creating player...")
		spawn_player.rpc(1, $Players.get_safe_spawn_point())
		#$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		#$CanvasLayer/VBoxContainer/Label.text = "Client"
		pass

@rpc("any_peer")
func spawn_request():
	on_player_join(multiplayer.get_remote_sender_id())

func on_player_join(id : int) -> void:
	# this function only runs on the server
	if not multiplayer.is_server():
		return
	
	for child in get_children():
		if child is Player:
			var p: Player = child
			spawn_player.rpc_id(id, p.get_multiplayer_authority(), p.position)
	
	spawn_player.rpc(id,$Players.get_safe_spawn_point())
	# Sends information about new players to everyone
	Multiplayer.broadcast_player_info()
	

@rpc("reliable", "call_local")
func spawn_player(id: int, pos: Vector3) -> void:
	var server_conn: ServerConnection = Multiplayer.player_list.get(id)
	if server_conn != null and server_conn.player != null:
		return
	
	Debug.log("Creating player of id ",id)
	var new_player: Player = player.instantiate()
	
	new_player.position = pos
	new_player.name = "Player_" + str(id)
	add_child(new_player)
	new_player.set_authority(id) # we don't need to use RPC here since this function call is RPC'd
	
	
	if server_conn != null: # should only be == null if we started this level w/ F6
		server_conn.player = new_player
		CharacterSelect.assign_skin(id,server_conn.character_texture_id)
		# tell everyone about the new player and the new player the current players
		Debug.log("Spawning Player ", id, " at ", pos)
