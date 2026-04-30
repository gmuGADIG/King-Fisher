extends Node3D

@onready var normal_pool : CSGPolygon3D = $normal_pool
@onready var rare_pool : CSGPolygon3D = $rare_pool

# The areas of both pools
var normal_area : float
var rare_area : float

# The cached indices of the triangles that comprise the polygon
var normal_tris : PackedInt32Array ## Normal pool triangle index cache
var rare_tris : PackedInt32Array ## Rare pool triangle index cache

var rng : RandomNumberGenerator

# [DELETEME] The responsibility of this script is to manage the fish spawning in this particular pool.
# As such, timing is not within the scope of this script, but rather some other controller script.
# Furthermore, perhaps this polygon business should be the work of a separate script, 
# but i'm not sure where i'd begin to do something like that

func _ready() -> void:
	normal_area = get_poly_area(normal_pool)
	rare_area = get_poly_area(rare_pool)
	
	init_tri_cache()
	
	rng = RandomNumberGenerator.new()
	
	print("Normal pool polygonal area: ", normal_area)
	print("Rare pool polygonal area: ", rare_area)

## Spawns a fish.
func spawn_fish() -> void:
	# Determine which pool to use, first by using the areas of the pools as a whole
	var pool := get_random_pool()
	
	if (not pool):
		return
	
	# Choose random point within pool
	var point := get_random_point(pool)
	
	# Choose fish in loot table
	
	# Spawn fish
	
	pass

func get_random_point(poly:CSGPolygon3D) -> Vector3:
	var out : Vector3
	var tris : PackedInt32Array
	
	# Based off of which pool we're using, use the appropriate triangle weights 
	# and choose a triangle.
	if (poly == normal_pool):
		tris = normal_tris
	else:
		tris = rare_tris
	
	# Select a random teiangle using its areas as weight
	
	# Sample a random point in the triangle using the parallelogram method
	# INFO: https://blogs.sas.com/content/iml/2020/10/19/random-points-in-triangle.html (reference later)
	
	
	return out
	
func init_tri_cache() -> void:
	normal_tris = Geometry2D.triangulate_polygon(normal_pool.polygon)
	rare_tris = Geometry2D.triangulate_polygon(rare_pool.polygon)
	pass
	
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
	var points : PackedVector2Array = poly.polygon
	var num_points : int = points.size()
	
	if (num_points < 3):
		return 0.0 # must be at least a triangle
	
	var area = 0.0
	
	# Shoelace formula implementation
	for i in range(num_points):
		var u = points[i]
		var v = points[(i + 1) % num_points]
		area += (u.x * v.y) - (v.x * u.y)
	
	return abs(area) / 2
