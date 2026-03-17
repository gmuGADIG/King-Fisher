extends PhysicalBoneSimulator3D

var player: Player
var skeleton: Skeleton3D

# Syncs player entity and skeleton of the player
# Deferred due to needing to wait for player_items to have been initialized
func _ready():
	player = $"../../../.."
	skeleton = get_parent()

# Call this function
func ragdoll(duration: float):
	if multiplayer.is_server(): start_ragdoll.rpc(duration)
	else: ragdoll_request.rpc_id(1, duration)

# Has the Host call the ragdoll so everyone recieves it.
@rpc("any_peer", "reliable")
func ragdoll_request(duration: float):
	if multiplayer.is_server(): start_ragdoll.rpc(duration)

# Checks if the player's ragdoll is on the ground.
func is_ragdoll_on_floor() -> bool:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	var query = PhysicsRayQueryParameters3D.create(pelvis_pos, pelvis_pos + Vector3(0, -10, 0))
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
func is_valid_ground() -> bool:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	var query = PhysicsRayQueryParameters3D.create(pelvis_pos, pelvis_pos + Vector3(0, -25, 0))
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	return collision.has("position")

# Performs the actual ragdolling
@rpc("any_peer", "call_local", "reliable")
func start_ragdoll(duration: float):
	if not multiplayer.is_server() and multiplayer.get_remote_sender_id() != 1:
		Debug.log("Not the server, and not the client that triggered this, ignoring")
		return
	if player.is_ragdolled: return
	if !can_ragdoll(): return

	player.is_ragdolled = true
	physical_bones_start_simulation()

	await get_tree().create_timer(duration).timeout
	end_ragdoll()

# This is seperate so if something else happens, this fucntion can be called to end the ragdoll state if the start_ragdoll script breaks after ragdolling
func end_ragdoll() -> void:
	# If ragdoll is on the floor(Or close Enough) it will spawn the player at the ragdolls position.
	# If ragdoll isn't on valid ground(Clipped through map)
	if is_ragdoll_on_floor():
		player.global_position = self.get_node("Physical Bone Pelvis").global_position + Vector3(0, 5, 0)
	elif not is_valid_ground():
		var player_spawnpoints = get_tree().root.get_node("World/Players")
		if player_spawnpoints:
			player.global_position = player_spawnpoints.get_safe_spawn_point()
		else:
			Debug.log_err("No spawner found in scene, and player ragdolled onto invalid ground. Player will be teleported to world origin.")
			player.global_position = Vector3.ZERO + Vector3(0, 5, 0)

	physical_bones_stop_simulation()
	player.is_ragdolled = false
	skeleton.reset_bone_poses()

func can_ragdoll() -> bool:
	if player.wearing_helmet:
		Debug.log("Player has helmet, cannot ragdoll.")
		player.wearing_helmet = false
		return false
	return true
