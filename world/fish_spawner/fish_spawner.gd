extends CSGPolygon3D
class_name FishSpawner

enum Rates{
	NORMAL,
	HIGH
}

@export var fish_spawnrate : Rates

var rates : Array[float] = []

# The areas of both pools
var area : float

# The cached indices of the triangles that comprise the polygon
var tris : PackedInt32Array ## pool triangle index cache

# The areas of each triangle in both polygons
var triangle_weights : Array[float]

var rng : RandomNumberGenerator

# [DELETEME] The responsibility of this script is to manage the fish spawning in this particular pool.
# As such, timing is not within the scope of this script, but rather some other controller script.
# Furthermore, perhaps this polygon business should be the work of a separate script, 
# but i'm not sure where i'd begin to do something like that

func _ready() -> void:
	hide()
	#assert(fish_spawnrate != null, "Missing fish spawn rate")
	
	match fish_spawnrate:
		Rates.NORMAL:
			rates = [1,1,1,1]
		Rates.HIGH:
			rates = [1,1,1,1]
	
	area = get_poly_area()
	
	init_tri_cache()
	
	rng = RandomNumberGenerator.new()
	
	print("pool polygonal area: ", area)

## Gets a random point on the given CSGPolygon
func get_random_point() -> Vector3:
	
	# Select a random teiangle using its areas as weight
	rng.randomize()
	var index = rng.rand_weighted(PackedFloat32Array(triangle_weights))
	
	# Sample a random point in the triangle using the parallelogram method
	# INFO: https://blogs.sas.com/content/iml/2020/10/19/random-points-in-triangle.html (reference later)
	
	var a = polygon[tris[index * 3]]
	var b = polygon[tris[index * 3 + 1]]
	var c = polygon[tris[index * 3 + 2]]
	
	var result = random_point_in_triangle(a, b, c)
	
	return global_position + Vector3(result.x, 0, result.y)

## Takes three points on a 2D plane and returns a random point using the paralellogram method.
func random_point_in_triangle(a:Vector2, b:Vector2, c:Vector2) -> Vector2:
	# make two vectors
	var ab = b - a
	var ac = c - a

	var u = randf()
	var v = randf()

	# "reflect" from other side of paralellogram divider into triangle
	if u + v > 1.0:
		u = 1.0 - u
		v = 1.0 - v

	# calculate the resulting point
	return a + (u * ab) + (v * ac)

## Initializes the triangle cache at the beginning to avoid repeated heavy computation.
func init_tri_cache() -> void:
	tris = Geometry2D.triangulate_polygon(polygon)
	
	# in case they had stuff
	triangle_weights.clear()
	
	for i in range(0, tris.size(), 3):
		var a = polygon[tris[i]]
		var b = polygon[tris[i + 1]]
		var c = polygon[tris[i + 2]]
		
		var area = 0.5 * abs(a.x*(b.y - c.y) + b.x*(c.y - a.y) + c.x*(a.y - b.y))
		
		triangle_weights.append(area)
	
	pass


## An implementation of the shoelace formula to calculare the total area of a polygon.
func get_poly_area() -> float:
	var points : PackedVector2Array = polygon
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

func pick_rarity() -> Fish.Grade:
	var type : int = rng.rand_weighted(rates)
	var grade : Fish.Grade = type+1
	
	return grade
