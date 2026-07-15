extends PhysicalBoneSimulator3D

@export var player: Player
@export var ragdoll_icon : Texture
var skeleton: Skeleton3D
# This is for if the item prevents getting up from not moving
var check_movement_toggle = true

# Syncs player entity and skeleton of the player
# Deferred due to needing to wait for player_items to have been initialized
func _ready():
	skeleton = get_parent()

var timer := 0.0
var next_check := 0.0
func _process(delta: float) -> void:
	if not player.is_ragdolled or not check_movement_toggle: return
	if timer >= next_check:
		next_check = timer + 1
		check_movement()
	else:
		timer = timer + delta

# Call this function
# Second variable is optional, set it to true to force players to wait the entire duration
func ragdoll(duration: float, prevent_move_check: bool = false, force : bool = false):
	if multiplayer.is_server(): start_ragdoll.rpc(duration, prevent_move_check, force)
	else: ragdoll_request.rpc_id(1, duration, prevent_move_check, force)

# Has the Host call the ragdoll so everyone recieves it.
@rpc("any_peer", "reliable")
func ragdoll_request(duration: float, prevent_move_check: bool, force : bool):
	if multiplayer.is_server(): start_ragdoll.rpc(duration, prevent_move_check, force)

# Checks if the player's ragdoll is on the ground.
func is_ragdoll_on_floor() -> bool:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	var query = PhysicsRayQueryParameters3D.create(pelvis_pos, pelvis_pos + Vector3(0, -15, 0))
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		var hit_pos = result.position
		var distance_to_ground = pelvis_pos.y - hit_pos.y
		return distance_to_ground < .2
	else:
		return false

# This validates if the player is on valid ground/has valid ground beneath them
# Returns an array where:
#     The first element is true|false for the ground position above the player
#     The second element is where the ground is below the player, or Vector3.ZERO 
#     if there's no ground below the player
func is_valid_ground() -> Array:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	var query = PhysicsRayQueryParameters3D.create(pelvis_pos, pelvis_pos + Vector3(0, -25, 0))
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision.has("position"):
		return [true, collision.position]
	else:
		return [false, Vector3.ZERO]

# Performs the actual ragdolling
@rpc("any_peer", "call_local", "reliable")
func start_ragdoll(duration: float, prevent_move_check: bool, force : bool = false):
	if not multiplayer.is_server() and multiplayer.get_remote_sender_id() != 1:
		Debug.log("Not the server, and not the client that triggered this, ignoring")
		return
	if player.is_ragdolled: return
	if not can_ragdoll(force): return
	if prevent_move_check:
		check_movement_toggle = false

	if player.moai_fish_active:
		duration -= player.ragdoll_time_decrease
	print("%s is ragdolled for %f!" % [player.name, duration])

	player.is_ragdolled = true
	player.cancel_fishing_minigame()
	physical_bones_start_simulation()

	player.set_name_visible(false)
	player.add_item_buff("Ragdoll",duration,ragdoll_icon)
	await get_tree().create_timer(duration).timeout
	if player.is_ragdolled:
		player.can_exit_ragdoll = true
		Debug.log("Player can Unragdoll")

# This is seperate so if something else happens, this fucntion can be called to end the ragdoll state if the start_ragdoll script breaks after ragdolling
# Call this to end ragdoll
func end_ragdoll(respawn : bool = false):
	if multiplayer.is_server(): confirm_end_ragdoll.rpc(respawn)
	else: end_ragdoll_request.rpc_id(1,respawn)

# Has the Host call the ragdoll so everyone recieves it.
@rpc("any_peer", "reliable")
func end_ragdoll_request(respawn : bool):
	if multiplayer.is_server(): confirm_end_ragdoll.rpc(respawn)

@rpc("any_peer", "call_local", "reliable")
func confirm_end_ragdoll(respawn : bool):
	# If ragdoll is on the floor(Or close Enough) it will spawn the player at the ragdolls position.
	# If ragdoll isn't on valid ground(Clipped through map)
	##NEEDS a respawn
	if player.force_respawn and not respawn:
		return
	
	if respawn:
		var player_spawnpoints = get_tree().current_scene.get_node("%Players")
		assert(player_spawnpoints,"no spawnpoint node???")
		player.global_position = player_spawnpoints.get_safe_spawn_point()
	else:
		player.global_position = self.get_node("Physical Bone Pelvis").global_position + Vector3(0, 1.5, 0)
	#if is_valid_ground() and !player.force_respawn:
		
	#elif not is_valid_ground()[0] or player.force_respawn:
		#
		#else:
			#Debug.log_err("No spawner found in scene, and player ragdolled onto invalid ground. Player will be teleported to world origin.")
			#player.global_position = Vector3.ZERO + Vector3(0, 1.5, 0)

	physical_bones_stop_simulation()
	player.is_ragdolled = false
	player.set_name_visible(true)
	skeleton.reset_bone_poses()

	#Reset values
	stopped_moving = false
	player.can_exit_ragdoll = false 
	player.force_respawn = false
	check_movement_toggle = true

func can_ragdoll(force : bool) -> bool:
	if not force:
		# All code that checks if the player can ragdoll should be here. 
		#If its a force ragdoll(Nothing can block it) means that the player is meant to ragdoll no-matter what.
		if player.wearing_helmet:
			Debug.log("Player has helmet, cannot ragdoll.")
			player.unequip_helmet()
			return force
	print("CAN RAGDOLL")
	return true

var stopped_moving := false
var last_pos := Vector3.ZERO
# Used for determining if the player's ragdoll has stopped moving
func check_movement() -> void:
	if stopped_moving or not player.is_ragdolled: return
	var pelv_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position

	if last_pos.is_equal_approx(pelv_pos):
		stopped_moving = true
	else:
		last_pos = pelv_pos

# Call this to check if the ragdoll is still moving enough
func is_moving() -> bool: return check_movement_toggle and stopped_moving
