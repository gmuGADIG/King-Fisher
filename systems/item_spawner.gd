extends CollisionShape3D
## ITEM SPAWNER
## This Node3D hovers ominously above every level. It can be told to spawn an item.
## It takes a random X/Z offset within a given range. Then it raycasts down to check for land.
## If the raycast hits land, it spawns an item there. If it doesn't, it re-rolls and tries again.

@export var disable_spawning: bool = false

@export var items: Array[PackedScene]
@export var spawn_rate: float = 4.0
@export var spawn_timer: Timer

@export var max_items: int = 12
var spawned_items: int = 0

func _ready() -> void:
	if disable_spawning: queue_free()
	
	
	# Make sure designers aren't scaling the object instead of changing the actual shape
	assert(scale==Vector3.ONE, "Please set the scale of the Item Spawner to 1,1,1!")
	
	if multiplayer.is_server():
		# Update spawn timer to item spawn rate set in inspector.
		spawn_timer.wait_time = spawn_rate
	else:
		# Delete the spawn timer since the host is the only one who needs to count down.
		spawn_timer.queue_free()
	
	# Destroy the label that shows the item spawner in the editor
	for child in get_children():
		if child is Label3D: child.queue_free()


func getItemSpawnLocation() -> void:
	var locationFound: bool = false
	for i in 100:
		
		# Get random point in area
		var rayOffsetX: float = randf_range(-shape.size.x/2, shape.size.x/2)
		var rayOffsetZ: float = randf_range(-shape.size.z/2, shape.size.z/2)
		
		var rayCastOrigin = Vector3(self.position.x + rayOffsetX, self.position.y, self.position.z + rayOffsetZ)
		var rayCastDestination: Vector3 = rayCastOrigin - Vector3(0,200,0)
		# print("firing raycast from " + str(rayCastOrigin))
		
		# Fire raycast
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(rayCastOrigin, rayCastDestination)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		# Check if you hit any ground on layer 1.

		if result && result.collider.collision_layer==1:
			#print(result.collider.collision_layer==1)
			#print("Hit at point: ", result.position)
			
			# If so, spawn random fish
			if items.size()!=0:
				var itemIndex = randi_range(0, items.size()-1)
				spawnItem.rpc(itemIndex, result.position)
				locationFound=true
				# Increments to make sure no more than max_items lie around at once.
				spawned_items+=1
		
		if locationFound:
			break
	if not locationFound:
		Debug.log("Item Spawn location not found? rare occurance or bug?")
	
# RPC is set to authority since the host can be the one to handle this stuff.
@rpc("authority", "call_local")
func spawnItem(itemIndex: int, spawnPosition: Vector3) -> void:
	var newItem: Item = items[itemIndex].instantiate()
	newItem.position = spawnPosition
	add_sibling(newItem)
	newItem.item_got_picked_up.connect(_on_item_got_picked_up)


func _on_spawn_timer_timeout():
	# The timer loops. Every time it ends, check if there's a slot open and roll for another location.
	if multiplayer.is_server() && spawned_items<max_items:
		getItemSpawnLocation()

func _on_item_got_picked_up():
	# Only the server keeps track of held items.
	if multiplayer.is_server():
		spawned_items -= 1
