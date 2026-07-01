class_name Player
extends CharacterBody3D

enum AimMode{
	NONE,
	FISHING_ROD,
	ITEM
}

const GRAVITY := 30.
const FOOTSTEP_MIN_HORIZONTAL_SPEED := 0.1

# Ragdoll
@export var player_mesh: PlayerMesh
@onready var ragdoll_phys : PhysicalBoneSimulator3D = player_mesh.bones
var is_ragdolled := false
var can_exit_ragdoll := false
var force_respawn := false

@export_category("Variables")
@export var speed := 10.
var slow_timer := 0.0
var speed_modifier := 0.0
var jump_height := 15.

var last_pos : Vector3 = Vector3.ZERO
var held_item: Item
var fish_inventory: Array[Fish]
var score: int = 0
@onready var held_item_ui: HeldItemUI = $HeldItem
var aim_mode : AimMode = AimMode.NONE

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

var current_fishing_shadow : FishShadow = null

# footstep timing.
var _footstep_accum_distance := 0.0
var _footstep_time_since_last := 0.0

var _landing_time_since_last := 0.0

var _jump_event_id: int = 0
var _last_played_jump_event_id: int = -1

# Item Variables
var wearing_helmet := false
var helmet_node : Node = null
var golden_worm_active := false
var has_ziplock_bag := false

@export_category("Sushi Grade Buffs")
## Catching "Oh My Cod" decreases the accuracy thresholds for all
## fish in the fishing minigame by this amount.
@export var accuracy_threshold_decrease: float
## Catching "Swordfish" increases the ragdoll time inflicted on
## opponents with the Rubber Mallet item by this amount.
@export var ragdoll_time_increase: float
var swordfish_active: bool = false
## Catching "Moai Fish" decreases the ragdoll time inflicted on
## the player by this amount.
@export var ragdoll_time_decrease: float
var moai_fish_active: bool = false
## Catching "Fish with Legs" or "Angel & Devil" 50% chance
## buffs the player's movement speed by this amount.
@export var movement_speed_increase: float
## Catching "The 'Fish'" or "Angel & Devil" 50% chance
## increases the player's jump height by this amount.
@export var jump_height_increase: float

#@onready var livewell : Livewell = $LivewellMenu

var fishing_minigame : FishingMinigame


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
	fishing_minigame = %FishingMiniGame
	fishing_minigame.fishing_finished.connect(on_fishing_finished)

func _process(delta: float) -> void:
	# Prevents errors when disconnection happens
	if not multiplayer.has_multiplayer_peer(): return
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
	if UIState.player_keyboard_input_blocked:
		input = Vector2.ZERO
	var movement_dir : Vector2 = input.rotated(-deg_to_rad(camera_yaw))		
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.y * speed

	
	if not is_on_floor():
		velocity += GRAVITY * delta * Vector3.DOWN
	
	if is_on_floor() and Input.is_action_just_pressed("jump") and not UIState.player_keyboard_input_blocked:
		velocity.y = jump_height
		_jump_event_id += 1
		_on_jump_event(_jump_event_id)
		sync_jump_event.rpc(_jump_event_id)

	if input != Vector2.ZERO:
		player_mesh.turn_towards(movement_dir.rotated(-PI/2), delta)
	
	
		

func _physics_process(delta: float) -> void:
	# Prevents errors when disconnection happens
	if not multiplayer.has_multiplayer_peer(): return
	var was_on_floor := is_on_floor()
	var pre_velocity_y := velocity.y
	if is_multiplayer_authority():
		sync_velocity.rpc(velocity)
		handle_camera_position()
	
	if slow_timer > 0:
		Debug.log("player %s has been slowed!" % name, "; speed_mod = ", speed_modifier)
		velocity.x *= 1. - speed_modifier
		velocity.z *= 1. - speed_modifier
	
	#Debug.log("velocity ", velocity)

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
		held_item_ui.show()
		audio_listener.make_current()
	else:
		held_item_ui.hide()

@rpc("reliable","authority","call_remote")
func update_camera() -> void:
	camera.current = get_multiplayer_authority() == multiplayer.get_unique_id()

func _input(event: InputEvent) -> void:
	# Prevents errors when disconnection happens
	if not multiplayer.has_multiplayer_peer(): return
	if not is_multiplayer_authority(): return
	
	_keyboard_input(event)
	_mouse_input(event)
		
func _keyboard_input(event : InputEvent) -> void:
	if UIState.player_keyboard_input_blocked:
		return
	
	if event.is_action_pressed("scoreboard"):
		pass
	if event.is_action_pressed("test1"):
		ragdoll_phys.ragdoll(1)
		# force_respawn = true
		pass
	if event.is_action_pressed("print_players"):
		Debug.print_players()
	pass

func _mouse_input(event : InputEvent) -> void:
	if UIState.player_click_input_blocked:
		return
	
	match aim_mode:
		AimMode.NONE:
			if event.is_action_pressed("cast_rod"):
				%Aiming.start_aiming()
			if event.is_action_pressed("use_item"):
				if held_item == null:
					return
				# print("item aim")
				if held_item is ThrowableItem:
					# print("item aim")
					%Aiming.start_aiming(AimMode.ITEM)
				else:
					use_held_item.rpc()
			if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				camera_yaw += -event.relative.x * Options.mouse_sensitivity
				$CameraMount.rotation.y = deg_to_rad(camera_yaw)
		AimMode.FISHING_ROD:
			if event.is_action_released("cast_rod"):
				%Aiming.stop_aiming()
				$Sounds/CastRod.play()
				var body : Node = $Aiming/AimRayCast.get_collider()
				if body is FishShadow:
					if body.currently_fishing:
						return
					body.current_fishing_state.rpc(true)
					current_fishing_shadow = body
					
					##TODO: Play Fishing Minigame
					Debug.log("fish: ",body.fish)
					fishing_minigame.start(body.fish)
					
		AimMode.ITEM:
			##This point should only reachable if the item held is throwable
			if event.is_action_released("use_item"):
				assert(held_item != null, "Item is null somehow")
				assert(held_item is ThrowableItem, "Thrown item is somehow not throable")
				var throw_item : ThrowableItem = held_item
				throw_item.use_throwable.rpc(%Aiming.get_aim_pos())
				held_item = null
				%Aiming.stop_aiming()
			pass
		_:
			assert(false,"Invalid Aim Mode")
			

	
		
		
		###AAAAAAAAAAa
		#if Input.is_action_just_pressed("cast_rod"):
			#%Aiming.start_aiming()
	#if Input.is_action_just_released("cast_rod"):
		#%Aiming.stop_aiming()
		#Debug.log("TODO: fire fishing rod at global position ", %Aiming.get_aim_pos())
		#
	#if Input.is_action_just_pressed("use_item") && is_instance_of(held_item, ThrowableItem):
		#%Aiming.start_aiming(true)
	#if Input.is_action_just_released("use_item") && is_instance_of(held_item, ThrowableItem):
		#var item := held_item as ThrowableItem
		#item.use_throwable(%Aiming.get_aim_pos())
		#held_item = null
		#item = null
		#%Aiming.stop_aiming()
	
	## TODO remove these two debug actions
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/sushi/fish_seven.tres")
		give_fish_serialized.rpc(newFish.serialize())
	if event.is_action_pressed("remove_fish"):
		var newFish : Fish = load("res://fish/sushi/fish_seven.tres")
		take_fish_serialized.rpc(newFish.serialize())
		#take_fish(nes


@rpc("call_local")
func slow(time : float, speed_debuf : float):
	slow_timer = time
	speed_modifier = speed_debuf
	
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
	# TODO: Parent to player hand instead, with an offset for appropriate placement.
	# Item origin is center/pickup area. Item hold point is offset in pos+rot.
	item.reparent($DefaultPlayer, false)
	held_item = item
	held_item.player = self
	held_item.is_held = true
	held_item.position = Vector3.ZERO + Vector3(0,1,0)
	# Hide the item. Nobody will know you have it until you use it.
	held_item.visible=false
	held_item_ui.hold_item(held_item.item_name)
	# Don't play the sound unless we're the owning client
	if is_multiplayer_authority():
		$Sounds/PlayerPickupItem.play()
	if swordfish_active and held_item is RubberMallet:
		swordfish(held_item)

@rpc("call_local")
func use_held_item() -> void:
	# If you don't have an item, don't try and use a nonexistent item.
	if held_item==null:return
	held_item.visible = true
	held_item.use()
	held_item=null
	held_item_ui.clear_item()

func equip_helmet(node : Node) -> void:
	wearing_helmet = true
	helmet_node = node
	helmet_node.get_node("CollisionShape3D").queue_free()
	helmet_node.reparent(get_node("DefaultPlayer/PlayerSkeleton/Skeleton3D/Bones/Physical Bone Head"))
	helmet_node.position = Vector3(0, -0.2, 0.35) # So it fits the player's head
	helmet_node.rotation = Vector3((-2 * 3.14) / 9, 0, 0) # -40 degrees in radians
	

func unequip_helmet() -> void:
	if !wearing_helmet:
		return
	wearing_helmet = false
	helmet_node.queue_free()
	get_tree().current_scene.get_node("%GameHud").get_node("ActiveBuffs").remove_buff("Helmet")


##NOTICE: This is abusable as it is any_peer

func give_fish(fish : Fish) -> void:
	Debug.log("Player " + self.name + " got a " + fish.fish_name)
	fish_inventory.append(fish)
	score+=fish.get_score()
	if fish.grade == Fish.Grade.SUSHI:
		buff_player(fish)
	#livewell.addFish(fish)
	#TODO update livewell ui
	if is_multiplayer_authority():
		Livewell.update_inventory_visuals(fish_inventory,score)
	##%fishdex.caught_fish(fish)

func take_fish(fish: Fish) -> void:
	if fish_inventory.has(fish):
		fish_inventory.erase(fish)
		score-=fish.get_score()
		#TODO update livewell ui
		if is_multiplayer_authority():
			Livewell.update_inventory_visuals(fish_inventory,score)
		Debug.log("Player " + self.name +" lost a " + fish.fish_name)
	else:
		Debug.log("Player " + self.name + " doesn't have a " + fish.fish_name + " to take!")
	
##NOTICE: This is abusable as it is any_peer
@rpc("any_peer","reliable","call_local")
func give_fish_serialized(data : Array) -> void:
	give_fish(Fish.create(data[0],data[1]))

##NOTICE: This is abusable as it is any_peer
@rpc("any_peer","reliable","call_local")
func take_fish_serialized(data : Array) -> void:
	take_fish(Fish.create(data[0],data[1]))

func set_name_visible(val : bool) -> void:
	$PlayerId.visible = val

func on_fishing_finished(succeeded:bool) -> void:
	if succeeded:
		var fish : Fish = current_fishing_shadow.fish
		if is_multiplayer_authority():
			match fish.grade:
				Fish.Grade.LEFTOVERS:
					$Sounds/LeftoverCatch.play()
				Fish.Grade.FRESH:
					$Sounds/FreshCatch.play()
				Fish.Grade.PREMIUM:
					$Sounds/PremiumCatch.play()
				Fish.Grade.SUSHI:
					$Sounds/SushiCatch.play()
				_:
					$Sounds/LeftoverCatch.play()
				
		current_fishing_shadow.kill_fish_shadow.rpc()
		give_fish_serialized.rpc(fish.serialize())
	else:
		if is_multiplayer_authority():
			$Sounds/FishCatchFail.play()
		current_fishing_shadow.current_fishing_state.rpc(false)
	current_fishing_shadow = null

@rpc("any_peer","call_local","reliable")
func apply_bone_force(vec : Vector3) -> void:
	for node : Node in ragdoll_phys.get_children():
		if node is PhysicalBone3D:
			print("Bone found")
			node.apply_central_impulse(vec)

func add_item_buff(buff_name : String, duration : float, texture : Texture2D) -> void:
	get_tree().current_scene.get_node("%GameHud").get_node("ActiveBuffs").add_buff(buff_name, duration, texture)

##Incredibly evil function of bad code design
func remove_item_buff(buff_name : String) -> void:
	match buff_name:
		"Golden Worm":
			golden_worm_active = false
		"Ziplock Bag":
			has_ziplock_bag = false
		"Helmet", "Ragdoll":
			pass
		_:
			assert(false,"invalid buff")
		

## The player is granted specific buffs after catching sushi grade fish.
func buff_player(fish: Fish):
	# TODO: Are these buffs stackable?
	match fish.fish_name:
		"Fish Seven":
			# 6 or 7% increase to all stats
			speed *= 1.06 if randf() < 0.5 else 1.07
			jump_height *= 1.06 if randf() < 0.5 else 1.07
			print("%s speed: %f jump: %f Fish seven!" % [name, speed, jump_height])
			# TODO: what other stats are buffed?
		"Oh My Cod":
			# Decrease to the accuracy threshold in the fishing minigame
			fishing_minigame.leftovers_accuracy_requirement -= accuracy_threshold_decrease
			fishing_minigame.fresh_accuracy_requirement -= accuracy_threshold_decrease
			fishing_minigame.premium_accuracy_requirement -= accuracy_threshold_decrease
			fishing_minigame.sushi_accuracy_requirement -= accuracy_threshold_decrease
			print(
				"%s leftover: %f fresh: %f premium: %f sushi: %f Oh my cod!" % [
					name,
					fishing_minigame.leftovers_accuracy_requirement,
					fishing_minigame.fresh_accuracy_requirement,
					fishing_minigame.premium_accuracy_requirement,
					fishing_minigame.sushi_accuracy_requirement
				]
			)
		"Sword Fish":
			# Increase ragdoll time for enemies you hit
			swordfish_active = true
			print("%s Swordfish Active" % name)
		"Angel & Devil":
			# 50% chance to buff Jump or Movement
			if randf() < 0.5:
				speed += movement_speed_increase
			else:
				jump_height += jump_height_increase
			print("%s Angel (speed): %f devil (jump): %f" % [name, speed, jump_height])
		"Fish With Legs":
			# Buff to Movement speed
			speed += movement_speed_increase
			print("%s has legs! Speed: %f" % [name, speed])
		'The "Fish"':
			# Increased Jump Height
			jump_height += jump_height_increase
			print("%s can now jump to %f! Is this really a fish..." % [name, jump_height])
		"Moai Fish":
			# Decreased ragdoll time for yourself
			moai_fish_active = true
			# The decrease is applied in ragdoll.start_ragdoll()
			print("%s Moai Active" % name)
		_:
			print("No buff exists for %s!" % fish.fish_name)

## The Swordfish increases ragdoll time for enemies the player hits.
## This will run whenever a rubber mallet is picked up to increase the default time.
func swordfish(mallet: RubberMallet):
	mallet.ragdollTime += ragdoll_time_increase
