class_name WorldBase
extends Node3D

@export var player : PackedScene
@export var ragdoll_spawner : PackedScene

func _ready() -> void:
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		Debug.log("Creating player...")
		spawn_player.rpc(1, Vector3.ZERO)
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"
		
	if ragdoll_spawner != null:
		$ragdoll_spawner.add_spawnable_scene(ragdoll_spawner.resource_path)
	
	$ragdoll_spawner.spawn_function = Callable(self, "_spawn_ragdoll_instance")

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
	

func _spawn_ragdoll_instance(data) -> Node:
	var instance = ragdoll_spawner.instantiate()
	if typeof(data) == TYPE_DICTIONARY and data.has("position"):
		instance.global_position = data.position
	add_child(instance)
	return instance

# Call this function to spawn a ragdoll at a given position
func spawn_ragdoll(_position: Vector3) -> void:
	if multiplayer.is_server():
		$ragdoll_spawner.spawn({"position": _position})
