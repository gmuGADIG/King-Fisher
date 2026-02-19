class_name WorldBase
extends Node3D

@export var player : PackedScene

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
