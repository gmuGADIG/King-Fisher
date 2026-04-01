class_name Player
extends CharacterBody3D

const GRAVITY := 30.
const FOOTSTEP_MIN_HORIZONTAL_SPEED := 0.1

# Ragdoll
@export_group("Scenes")
@export var ragdoll : PackedScene
var is_ragdolled := false
@onready var ragdoll_phys : PhysicalBoneSimulator3D = $Body/Armature/Skeleton3D/Bones
var can_exit_ragdoll := false

@export_category("Variables")
@export var speed := 10.

var last_pos : Vector3 = Vector3.ZERO
var held_item: Item
var is_aiming := false

@onready var camera_mount : Node3D = $CameraMount
@onready var camera : Camera3D = camera_mount.get_node("Camera3D")
@onready var audio_listener : AudioListener3D = $AudioListener3D

#Jump sound
@onready var jump_sound : AudioStreamPlayer3D = $Sounds/PlayerJump

@onready var landing_grass_sound : AudioStreamPlayer3D = $Sounds/PlayerLandGrass
@onready var landing_stone_sound : AudioStreamPlayer3D = $Sounds/PlayerLandStone

# Footsteps
@onready var footsteps_grass : AudioStreamPlayer3D = $Sounds/FootstepsGrass
@onready var footsteps_stone : AudioStreamPlayer3D = $Sounds/FootstepsStone

# Distance between footstep sounds
@export var footstep_distance : float = 1.0
@export var min_footstep_period : float = 0.5

@export var landing_velocity_threshold: float = 6.0
@export var min_landing_period: float = 0.15

enum FootstepState {GRASS, STONE, SNOW}
var footstep_state : FootstepState = FootstepState.GRASS

# footstep timing.
var _footstep_accum_distance := 0.0
var _footstep_time_since_last := 0.0

var _landing_time_since_last := 0.0

var _jump_event_id: int = 0
var _last_played_jump_event_id: int = -1

# Item Variables
var wearing_helmet := false
var golden_worm_active := false
var has_ziplock_bag := false

@onready var livewell : Control = $LivewellMenu

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
	last_pos = global_position
	_footstep_accum_distance = 0.0
	# Allow an immediate first step once enough distance is accumulated.
	_footstep_time_since_last = min_footstep_period
	_landing_time_since_last = min_landing_period
	_jump_event_id = 0
	_last_played_jump_event_id = -1

func _process(delta: float) -> void:
	# don't process input if ragdolled
	if is_ragdolled:
		%Aiming.stop_aiming()
		velocity = Vector3.ZERO
		if (can_exit_ragdoll or ragdoll_phys.is_moving()) and Input.is_action_just_pressed("jump"):
			ragdoll_phys.end_ragdoll()
		return
	# don't process input if this is not our player
	if not is_multiplayer_authority(): return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir : Vector2 = input.rotated(-deg_to_rad(camera_yaw))
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.y * speed

	if not is_on_floor():
		velocity += GRAVITY * delta * Vector3.DOWN
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = 15.
		_jump_event_id += 1
		_on_jump_event(_jump_event_id)
		sync_jump_event.rpc(_jump_event_id)

	if input != Vector2.ZERO:
		$Body.turn_towards(movement_dir.rotated(-PI/2), delta)
	
	if Input.is_action_just_pressed("cast_rod"):
		%Aiming.start_aiming()
	if Input.is_action_just_released("cast_rod"):
		%Aiming.stop_aiming()
		Debug.log("TODO: fire fishing rod at global position ", %Aiming.get_aim_pos())

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	var pre_velocity_y := velocity.y
	if is_multiplayer_authority():
		sync_velocity.rpc(velocity)
		handle_camera_position()

	move_and_slide()
	_update_footsteps(delta)
	_update_landing_sfx(delta, was_on_floor, pre_velocity_y)

var old_cam_pos = Vector3.ZERO
func handle_camera_position() -> void:
	if is_ragdolled:
		if old_cam_pos == Vector3.ZERO:
			old_cam_pos = camera.position

		var target_pos = ragdoll_phys.get_node("Physical Bone Pelvis").global_position
		camera_mount.global_position = target_pos
		camera.position = old_cam_pos
	else:
		if old_cam_pos != Vector3.ZERO:
			camera.position = old_cam_pos
			old_cam_pos = Vector3.ZERO
		camera_mount.position = Vector3.ZERO

@rpc("reliable","authority","call_local")
func set_authority(id : int):
	set_multiplayer_authority(id)
	update_camera()
	if id == multiplayer.get_unique_id():
		audio_listener.make_current()

@rpc("reliable","authority","call_remote")
func update_camera() -> void:
	camera.current = get_multiplayer_authority() == multiplayer.get_unique_id()

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return

	if event.is_action_pressed("scoreboard"):
		pass
	if event.is_action_pressed("test1"):
		ragdoll_phys.ragdoll(10, true)
	if event.is_action_pressed("print_players"):
		Debug.print_players()
	if event.is_action_pressed("use_item"):
		#TODO: Don't let this happen if the player is aiming.
		use_held_item.rpc()
	
	
	if not is_aiming:
		if event.is_action_pressed("use_item"):
			use_held_item.rpc()
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_yaw += -event.relative.x * Options.mouse_sensitivity
			$CameraMount.rotation.y = deg_to_rad(camera_yaw)


@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel

@rpc("unreliable")
func sync_jump_event(event_id: int) -> void:
	_on_jump_event(event_id)

func _on_jump_event(event_id: int) -> void:
	if event_id <= _last_played_jump_event_id:
		return
	if is_ragdolled:
		return

	_last_played_jump_event_id = event_id

	if jump_sound.playing:
		jump_sound.stop()
	jump_sound.play()

func _update_footsteps(delta: float) -> void:
	if is_ragdolled:
		_footstep_accum_distance = 0.0
		_footstep_time_since_last = min_footstep_period
		last_pos = global_position
		return

	_footstep_time_since_last += delta

	# Horizontal distance traveled since last physics tick.
	var current_pos := global_position
	var delta_pos := current_pos - last_pos
	delta_pos.y = 0.0
	last_pos = current_pos
	var horiz_dist := delta_pos.length()

	if not is_on_floor():
		_footstep_accum_distance = 0.0
		return

	var horiz_speed := Vector2(velocity.x, velocity.z).length()
	if horiz_speed < FOOTSTEP_MIN_HORIZONTAL_SPEED:
		_footstep_accum_distance = 0.0
		return

	_footstep_accum_distance += horiz_dist

	if footstep_distance <= 0.0:
		return

	# Enforce a max footstep rate
	if _footstep_accum_distance >= footstep_distance and _footstep_time_since_last >= min_footstep_period:
		_play_footstep()
		_footstep_accum_distance = max(0.0, _footstep_accum_distance - footstep_distance)
		_footstep_time_since_last = 0.0

func _play_footstep() -> void:
	var p: AudioStreamPlayer3D = footsteps_grass
	match footstep_state:
		FootstepState.GRASS:
			p = footsteps_grass
		FootstepState.STONE:
			p = footsteps_stone
		FootstepState.SNOW:
			# No SNOW stream wired yet
			p = footsteps_grass

	if p == null:
		return

	if p.playing:
		p.stop()
	p.play()

func _update_landing_sfx(delta: float, was_on_floor: bool, pre_velocity_y: float) -> void:
	_landing_time_since_last += delta

	if is_ragdolled:
		_landing_time_since_last = min_landing_period
		return

	if was_on_floor:
		return
	if not is_on_floor():
		return

	if _landing_time_since_last < min_landing_period:
		return

	var impact_speed := -pre_velocity_y
	if impact_speed < landing_velocity_threshold:
		return

	_play_landing_sfx()
	_landing_time_since_last = 0.0

func _play_landing_sfx() -> void:
	var p: AudioStreamPlayer3D = landing_grass_sound
	match footstep_state:
		FootstepState.GRASS:
			p = landing_grass_sound
		FootstepState.STONE:
			p = landing_stone_sound
		FootstepState.SNOW:
			p = landing_grass_sound

	if p == null:
		return

	if p.playing:
		p.stop()
	p.play()

func pick_up_item(item: Item) -> void:
	# TODO: Parent it to the player's hand?
	# I imagine there might even be item-specific animations, but I think this should be extendable enough to accomodate that. Imagine an enum of item hold anim types and the item just reports which one it uses...
	
	# If you already have an item, don't pick up another one.
	if held_item!=null: return
	item.reparent(self, false)
	held_item = item
	held_item.is_held = true
	held_item.position = Vector3.ZERO
	# Hide the item. Nobody will know you have it until you use it.
	held_item.visible=false

@rpc("call_local")
func use_held_item() -> void:
	# If you don't have an item, don't try and use a nonexistent item.
	if held_item==null:return
	held_item.use()
	held_item=null

func give_fish(fish : Fish) -> void:
	Debug.log("Player got fish!")
	livewell.addFish(fish)
	
func take_fish(fish : Fish) -> void:
	Debug.log("Player lost fish!")
	livewell.removeFish(fish)

func set_name_visible(val : bool) -> void:
	$PlayerId.visible = val
