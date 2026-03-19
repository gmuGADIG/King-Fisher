extends CollisionShape3D
## ITEM SPAWNER
## This Node3D hovers ominously above every level. It can be told to spawn an item.
## It takes a random X/Z offset within a given range. Then it raycasts down to check for land.
## If the raycast hits land, it spawns an item there. If it doesn't, it re-rolls and tries again.

@export var items: Array[PackedScene]
@export var spawnRate: float = 0.2
@export var spawnTimer: Timer
func _ready() -> void:
	# Make sure designers aren't scaling the object instead of changing the actual shape
	assert(scale==Vector3.ONE, "Please set the scale of the Item Spawner to 1,1,1!")
	
	if multiplayer.is_server():
		# Update spawn timer to item spawn rate set in inspector.
		spawnTimer.wait_time = spawnRate
	else:
		# Delete the spawn timer since the host is the only one who needs to count down.
		spawnTimer.queue_free()
	
	# Destroy the label that shows the item spawner in the editor
	for child in get_children():
		if child is Label3D: child.queue_free()


func getItemSpawnLocation() -> void:
	var locationFound: bool = false
	while(!locationFound):
		
		# Get random point in area
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		var rayOffsetX: float = rng.randf_range(-shape.size.x/2, shape.size.x/2)
		var rayOffsetZ: float = rng.randf_range(-shape.size.z/2, shape.size.z/2)
		
		var rayCastOrigin = Vector3(self.position.x + rayOffsetX, self.position.y, self.position.z + rayOffsetZ)
		var rayCastDestination: Vector3 = rayCastOrigin - Vector3(0,200,0)
		print("firing raycast from " + str(rayCastOrigin))
		
		# Fire raycast
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(rayCastOrigin, rayCastDestination, 1)
		var result = space_state.intersect_ray(query)
		
		# Check if you hit anything. Because the query is masked to only look at layer 1, "World".
		if result:
			print("Hit at point: ", result.position)
			# If so, spawn random fish
			if items.size()!=0:
				var itemIndex = rng.randi_range(0, items.size()-1)
				spawnItem.rpc(itemIndex, result.position)
				locationFound=true

# RPC is set to authority since the host can be the one to handle this stuff.
@rpc("authority", "call_local")
func spawnItem(itemIndex: int, spawnPosition: Vector3) -> void:
	var newItem = items[itemIndex].instantiate()
	newItem.position = spawnPosition
	add_sibling(newItem)


func _on_spawn_timer_timeout():
	if multiplayer.is_server():
		getItemSpawnLocation()
