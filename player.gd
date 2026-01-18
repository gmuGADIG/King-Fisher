class_name Player
extends CharacterBody2D

@export var speed := 500.

func _ready() -> void:
	%BoxingGlove.hide()

func quantize_direction(vec: Vector2, directions: int) -> Vector2:
	if vec == Vector2.ZERO:
		return Vector2.ZERO
	
	var angle = vec.angle()
	var sector_size = TAU / directions
	var snapped_angle = round(angle / sector_size) * sector_size
	
	return Vector2.from_angle(snapped_angle)

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

func _input(event: InputEvent) -> void:
	print("playerlist:")
	for player in Multiplayer.player_list:
		print(player)

@rpc
func sync_velocity(vel: Vector2) -> void:
	velocity = vel
