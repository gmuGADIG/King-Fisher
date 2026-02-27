class_name WorldBase
extends Node3D

@export var player : PackedScene

func _ready() -> void:
	
	if multiplayer.is_server():
		Multiplayer.new_player.connect(on_player_join)
		Debug.log("Creating player...")
		spawn_player(1)
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"
	pass

func on_player_join(id : int) -> void:
	spawn_player(id)

func spawn_player(id: int) -> void:
	Debug.log("Creating player of id ",id)
	var new_player: Player = player.instantiate()
	# WARNING you HAVE to set position before adding child or else you DIE.
	new_player.position = $Players.get_safe_spawn_point()
	$Players.add_child(new_player,true)
	
	new_player.set_authority.rpc(id)
	#new_player.update_camera.rpc_id(id)`
	
	Debug.log(new_player.position)
