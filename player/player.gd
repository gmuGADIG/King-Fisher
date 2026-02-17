class_name Player
extends CharacterBody3D

@export var speed := 10.
@export var player_model: String

var last_pos : Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector3(input.x,0,input.y) * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scoreboard"):
		# Get the current scene (your WorldBase node)
		var world = get_tree().get_current_scene() as WorldBase
		if world != null:
			# Spawn the ragdoll slightly above the player
			world.spawn_ragdoll(global_position + Vector3(0, 1, 0))
		else:
			print("WorldBase not found!")

@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel
