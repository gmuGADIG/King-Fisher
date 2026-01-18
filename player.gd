class_name Player
extends CharacterBody2D

@export var punch_direction := 1.
@export var speed := 500.
var can_punch := true
var punched := false

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
	
	if Input.is_action_just_pressed("punch"): punch.rpc()
	if not punched:
		var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

@rpc("call_local", "reliable")
func punch() -> void:
	if not can_punch: return
	
	can_punch = false
	
	%BoxingGlove.show()
	await create_tween().tween_property(%BoxingGlove, "position:x", 83 * sign(punch_direction), .05).finished
	await create_tween().tween_property(%BoxingGlove, "position:x", 0, .75).finished
	%BoxingGlove.hide()
	
	can_punch = true

@rpc
func sync_velocity(vel: Vector2) -> void:
	velocity = vel

func _on_boxing_glove_body_entered(body: Node2D) -> void:
	if body == self: return
	if body is Player:
		var player := body as Player
		player.punched = true
		var dir := global_position.direction_to(player.global_position)
		dir = quantize_direction(dir, 4)
		player.velocity = dir * 2000
		
		
		await get_tree().create_timer(.25).timeout
		
		player.punched = false
