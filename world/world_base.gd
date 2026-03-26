class_name WorldBase
extends Node3D

@export var player : PackedScene

func _ready() -> void:
	# TODO: do this without looking at the name
	if name != "Lobby":
		if not multiplayer.is_server():
			spawn_request.rpc_id(1)
	
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		Debug.log("Creating player...")
		spawn_player.rpc(1, $Players.get_safe_spawn_point())
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"

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
	

@rpc("reliable", "call_local")
func spawn_player(id: int, pos: Vector3) -> void:
	Debug.log("Creating player of id ",id)
	var new_player: Player = player.instantiate()
	
	new_player.position = pos
	add_child(new_player)
	new_player.set_authority(id) # we don't need to use RPC here since this function call is RPC'd
