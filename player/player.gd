class_name Player
extends CharacterBody3D

@export var speed := 10.

# The downward acceleration when in the air
@export var fall_acceleration := 75

var last_pos : Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector3(input.x,0,input.y) * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		last_pos.y = last_pos.y - (fall_acceleration * delta)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("print_players"):
		Debug.print_players()

@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel
