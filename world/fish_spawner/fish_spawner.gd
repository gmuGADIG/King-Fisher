extends Node3D

@onready var normal_pool : CSGPolygon3D = $normal_pool
@onready var rare_pool : CSGPolygon3D = $rare_pool

var normal_area : float
var rare_area : float

var rng : RandomNumberGenerator

# [DELETEME] The responsibility of this script is to manage the fish spawning in this particular pool.
# As such, timing is not within the scope of this script, but rather some other controller script.

func _ready() -> void:
	normal_area = get_poly_area(normal_pool)
	rare_area = get_poly_area(rare_pool)
	
	rng = RandomNumberGenerator.new()
	
	get_random_pool()
	
	print("Normal pool polygonal area: ", normal_area)
	print("Rare pool polygonal area: ", rare_area)

## Spawns a fish.
func spawn_fish() -> void:
	# Determine which pool to use, first by using the areas of the pools as a whole
	var pool := get_random_pool()
	
	if (not pool):
		return
	
	# Choose random point within pool
	
	# Choose fish in loot table
	
	# Spawn fish
	
	pass

func get_random_point(poly:CSGPolygon3D) -> Vector3:
	
	var out : Vector3
	return out
	
## Chooses either pool, weighted based off of their areas.
func get_random_pool() -> CSGPolygon3D:
	rng.randomize()
	var index = rng.rand_weighted(PackedFloat32Array([normal_area, rare_area]))
	match index:
		0:
			return normal_pool
		1:
			return rare_pool
		_:
			print("This shouldn't have happened, unless you added more pool areas w/o updating this.")
			return null

## An implementation of the shoelace formula to calculare the total area of a polygon.
func get_poly_area(poly:CSGPolygon3D) -> float:
	var points = poly.polygon
	var num_points = points.size()
	
	if (num_points < 3):
		return 0.0 # must be at least a triangle
	
	var area = 0.0
	
	# Shoelace formula implementation
	for i in range(num_points):
		var u = points[i]
		var v = points[(i + 1) % num_points]
		area += (u.x * v.y) - (v.x * u.y)
	
	return abs(area) / 2
