class_name Player
extends CharacterBody3D

const GRAVITY := 30.

# Ragdoll
@export_group("Scenes")
@export var ragdoll : PackedScene
@export var is_ragdolled := false

@export_category("Variables")
@export var speed := 10.

var last_pos : Vector3 = Vector3.ZERO
var held_item: Item

@onready var rd_utils: RagdollUtils = %RagdollUtils

##The angle in degrees of the camera
@onready var camera_yaw : float = 0:
	set(new_val):
		if new_val > 180.0:
			camera_yaw = new_val - 360.0
		elif new_val <= -180.0:
			camera_yaw = new_val + 360.0
		else:
			camera_yaw = new_val
		
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	# don't move when being ragdolled.
	# we are invisible, the ragdolling is doing all the movement
	# TODO: update ragdoll code with player character and skeleton
	if is_ragdolled: return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir : Vector2 = input.rotated(-deg_to_rad(camera_yaw))
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.y * speed

	if not is_on_floor():
		velocity += GRAVITY * delta * Vector3.DOWN
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = 10.

	if input != Vector2.ZERO:
		$Body.turn_towards(movement_dir, delta)

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		sync_velocity.rpc(velocity)
	move_and_slide()

@rpc("reliable","authority","call_local")
func set_authority(id : int):
	set_multiplayer_authority(id)
	update_camera()

@rpc("reliable","authority","call_remote")
func update_camera() -> void:
	var is_correct_camera = get_multiplayer_authority() == multiplayer.get_unique_id()
	$CameraMount/Camera3D.current = is_correct_camera

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw += -event.relative.x
		$CameraMount.rotation.y = deg_to_rad(camera_yaw)
	if event.is_action_pressed("scoreboard"):
		rd_utils.spawn_ragdoll.rpc(5)
	if event.is_action_pressed("print_players"):
		Debug.print_players()
	if event.is_action_pressed("use_item"):
		#TODO: Don't let this happen if the player is aiming.
		use_held_item.rpc()



@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel

func pick_up_item(item: Item) -> void:
	# TODO: Parent it to the player's hand?
	# I imagine there might even be item-specific animations, but I think this should be extendable enough to accomodate that. Imagine an enum of item hold anim types and the item just reports which one it uses...
	
	# If you already have an item, don't pick up another one.
	if held_item!=null: return
	item.reparent(self, false)
	held_item = item
	held_item.is_held = true
	held_item.position = Vector3.ZERO

@rpc("call_local")
func use_held_item() -> void:
	# If you don't have an item, don't try and use a nonexistent item.
	if held_item==null:return
	held_item.use()
	held_item=null
