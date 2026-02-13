class_name Player
extends CharacterBody3D

@export var speed := 10.
@export var player_model: String

# Physic Related Variables
@export_group("Movement Settings")
# Can we move?
@export var can_move := true
@export_range(0.1, 50.0, 0.19) var speed := 10.0
# Do we have gravity?
@export_group("Gravity Settings")
@export var has_gravity := true
@export var override_gravity := false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export_range(1, 500, 0.1) var overriden_gravity : float:
	set(value):
		if value < 1:
			push_warning("Overriding gravity to below 1 may cause physics issues. Use with caution.")
		overriden_gravity = value
# Can we jump?
@export var can_jump := true
@export_range(0.1, 500, 0.1) var jump_power: float = 1.0
# Can we run?
@export var can_run := true
@export_range(0.1, 500, 0.1, "or_greater") var camera_sens: float = 1.0
@export var sprint_speed := 15.0

# States
var mouse_captured: bool = false

# Directional
var move_direction := Vector2.ZERO
var look_direction := Vector2.ZERO

# Camera
@onready var camera: Camera3D = $player_camera

func _ready() -> void:
	if override_gravity:
		gravity = overriden_gravity
	
	$player_camera.make_current()
	# capture_mouse()

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_direction.x, 0, move_direction.y)
	var walk_direction: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	velocity = Vector3(walk_direction.x * speed * move_direction.length(), velocity.y, walk_direction.z * speed * move_direction.length())


	if not is_on_floor():
		velocity.y -= gravity * _delta
	elif Input.is_action_just_pressed("jump"): 
		velocity.y = jump_power
	
	sync_velocity.rpc(velocity)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("print_players"):
		Debug.print_players()

@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel


# Handles Camera Movement
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

@export var ball : PackedScene
@export var player : PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_direction = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	# if Input.is_action_just_pressed(&"Exit"): get_tree().quit()

	if Input.is_action_just_pressed(&"Exit") and mouse_captured: 
		release_mouse()
	if Input.is_action_just_pressed(&"Exit") and not mouse_captured: 
		capture_mouse()

	if Input.is_action_just_pressed(&"mouse1"):
		print("Spawning Player")
		var my_class_instance = WorldBase.new()
		my_class_instance.spawn_player(multiplayer.get_unique_id(), camera.global_transform.origin + camera.global_transform.basis.z * -2)
		# var new_player: Player = player.instantiate()
		# new_player.position = camera.global_transform.origin + camera.global_transform.basis.z * -2


func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_direction.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_direction.y * camera_sens * sens_mod, -1.5, 1.5)
