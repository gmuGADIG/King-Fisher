extends CollisionShape3D
## ITEM SPAWNER
## This Node3D hovers ominously above every level. It can be told to spawn an item.
## It takes a random X/Z offset within a given range. Then it raycasts down to check for land.
## If the raycast hits land, it spawns an item there. If it doesn't, it re-rolls and tries again.

@export var items: Array[PackedScene]


func _ready() -> void:
	# Make sure designers aren't scaling the object instead of changing the actual shape
	assert(scale==Vector3.ONE, "Please set the scale of the Item Spawner to 1,1,1!")
	
	# Destroy the label that shows the item spawner in the editor
	for child in get_children():
		if child is Label3D: child.queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		spawnItem()

func spawnItem() -> void:
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
	var query = PhysicsRayQueryParameters3D.create(rayCastOrigin, rayCastDestination, 2)
	var result = space_state.intersect_ray(query)
	
	# Check if you hit anything. Because the query is masked to only look at layer 2.
	if result:
		print("Hit at point: ", result.position)
		
		
		# If so, spawn random fish
	
		if items.size()!=0:
			var newItem = items[rng.randi_range(0, items.size()-1)].instantiate()
			newItem.position = result.position
			add_sibling(newItem)
	
	
