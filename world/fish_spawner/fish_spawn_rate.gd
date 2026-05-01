extends Resource
class_name FishSpawnRate

@export var leftovers_rate : int
@export var fresh_rate : int
@export var premium_rate : int
@export var sushi_rate : int

var rates : Array[int]

var rng : RandomNumberGenerator



func _init() -> void:
	rng = RandomNumberGenerator.new()
	rates = [leftovers_rate,fresh_rate,premium_rate,sushi_rate]
	
func pick_rarity() -> Fish.Grade:
	var type : int = rng.rand_weighted(rates)
	var grade : Fish.Grade = type+1
	return grade
