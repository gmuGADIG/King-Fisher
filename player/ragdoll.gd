class_name Ragdoll
extends RigidBody3D

@export var length := 10
@onready var player_mesh = $MeshInstance3D
@onready var player_collision = $CollisionShape3D

@rpc("reliable", "call_local")
func ragdoll(duration: int) -> void:
	player_mesh.hide()
	player_collision.disabled = true
	## spawn in the RigidBody or something
	
	await get_tree().create_timer(duration).timeout
	
	## despawn ragdoll
	player_mesh.show()
	player_collision.disabled = false
