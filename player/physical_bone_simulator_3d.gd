extends PhysicalBoneSimulator3D

var player: Player
var skeleton: Skeleton3D

@onready var selector = $"../../../../SpawnpointSelector"

# Syncs player entity and skeleton of the player
func _ready() -> void:
	player = $"../../../.."
	skeleton = get_parent()
	print(skeleton)

# Call this function
func ragdoll(duration: float):
	if multiplayer.is_server():
		trigger_ragdoll.rpc(duration)
	else:
		ragdoll_request.rpc_id(1, duration)

@rpc("any_peer", "reliable")
func ragdoll_request(duration: float):
	if not multiplayer.is_server(): return
	trigger_ragdoll.rpc(duration)

func ragdoll_ground_check() -> bool:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	print(pelvis_pos)
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

func is_valid_ground() -> bool:
	var pelvis_pos = player.ragdoll_phys.get_node("Physical Bone Pelvis").global_position
	var query = PhysicsRayQueryParameters3D.create(pelvis_pos, pelvis_pos + Vector3(0, -10, 0))
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	return collision.has("position")


@rpc("any_peer", "call_local", "reliable")
func trigger_ragdoll(duration: float):
	if not multiplayer.is_server() and multiplayer.get_remote_sender_id() != 1:
		print("Not the server, and not the client that triggered this, ignoring")
		return
	if player.is_ragdolled: return
	if is_multiplayer_authority():
		player.toggle_ragdoll_camera(true)
	
	player.is_ragdolled = true
	physical_bones_start_simulation()

	# The timer runs independently on every client
	await get_tree().create_timer(duration).timeout

	var ragdoll_pos = self.get_node("Physical Bone Pelvis").global_position
	if ragdoll_ground_check():
		player.global_position = ragdoll_pos
	if not is_valid_ground():
		var spawner = get_tree().get_first_node_in_group("Spawnpoints")
		if spawner:
			player.global_position = spawner.get_safe_spawn_point()
		else:
			Debug.log_err("No spawner found in scene, and player ragdolled onto invalid ground. Player will be teleported to world origin.")
			player.global_position = Vector3.ZERO


	physical_bones_stop_simulation()
	player.is_ragdolled = false
	skeleton.reset_bone_poses()
	if is_multiplayer_authority():
		player.toggle_ragdoll_camera(false)
