class_name WorldBase
extends Node3D

@export var player : PackedScene
@export var ragdoll : PackedScene

func _ready() -> void:
	
	if multiplayer.is_server():
		Multiplayer.new_player.connect(on_player_join)
		Debug.log("Creating player...")
		spawn_player(1, Vector3.ZERO)
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"
	pass

func on_player_join(id : int) -> void:
	spawn_player(id,Vector3.ZERO)

func spawn_player(id: int, pos: Vector3) -> void:
	Debug.log("Creating player of id ",id)
	var new_player: Player = player.instantiate()
	$Players.add_child(new_player,true)
	new_player.set_authority.rpc(id)
	new_player.position = pos
	
@rpc("reliable", "call_local", "any_peer")
func spawn_ragdoll(_position: Vector3) -> void:
	Debug.log("Spawning ragdoll at ", _position, "by player ", multiplayer.get_remote_sender_id())
	var new_ragdoll: Ragdoll = ragdoll.instantiate()
	add_child(new_ragdoll)
	new_ragdoll.position = _position

@rpc("reliable", "call_local", "any_peer")
func print_test(_msg: String) -> void:
	print("Message sent from: ", multiplayer.get_remote_sender_id(), " with message: ", _msg, "recieved by: ", multiplayer.get_unique_id())
