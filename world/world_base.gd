class_name WorldBase
extends Node3D

@export var player : PackedScene



func _ready() -> void:
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		Debug.log("Creating player...")
		spawn_player.rpc(1, Vector3.ZERO)
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"

func on_player_join(id : int) -> void:
	if not multiplayer.is_server():
		return
	
	
	for player_id in Multiplayer.player_list:
		if player_id != id:
			spawn_player.rpc_id(id,player_id,Vector3.ZERO)
	spawn_player.rpc(id,Vector3.ZERO)
	

@rpc("reliable", "call_local")
func spawn_player(id: int, pos: Vector3) -> void:
	Debug.log("Creating player of id ",id)
	var new_player: Player = player.instantiate()
	new_player.set_multiplayer_authority(id)
	
	
	add_child(new_player)
	new_player.position = pos
	#Debug.log(new_player.global_position)
	#new_player.position = Vector3.ZERO
	
