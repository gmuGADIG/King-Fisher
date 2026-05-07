extends Resource
class_name Fish

enum Grade{
	UNSET,
	LEFTOVERS,
	FRESH,
	PREMIUM,
	SUSHI,
}

static var leftover_fishes : Array[Fish] = [
	load("res://fish/leftovers/british_fish.tres"),
	load("res://fish/leftovers/patchwork_fish.tres")
]
static var fresh_fishes : Array[Fish] = [
	load("res://fish/fresh/angle_r_fish.tres"),
	load("res://fish/fresh/emo_bass_fish.tres")
]
static var premium_fishes : Array[Fish] = [
	load("res://fish/premium/gold_fish.tres")
]
static var sushi_fishes : Array[Fish] = [
	load("res://fish/sushi/fish_with_legs.tres"),
	load("res://fish/sushi/fish_seven.tres")
]

@export var fish_name : String
@export var grade : Grade
@export var sprite : Texture
@export_multiline var description : String


func _init() -> void:
	return

func get_grade_string() -> String:
	match grade:
		Grade.LEFTOVERS:
			return "Leftovers"
		Grade.FRESH:
			return "Fresh"
		Grade.PREMIUM:
			return "Premium"
		Grade.SUSHI:
			return "Sushi"
		_:
			return "Unset"

static func pick(grade : Fish.Grade) -> int:
	match grade:
		Fish.Grade.LEFTOVERS:
			return randi_range(0,leftover_fishes.size()-1)
		Fish.Grade.FRESH:
			return randi_range(0,fresh_fishes.size()-1)
		Fish.Grade.PREMIUM:
			return randi_range(0,premium_fishes.size()-1)
		Fish.Grade.SUSHI:
			return randi_range(0,sushi_fishes.size()-1)
		_:
			assert(false, "invalid grade")
			return -1

static func create(grade : Grade, index : int) -> Fish:
	match grade:
		Fish.Grade.LEFTOVERS:
			return leftover_fishes[index]
		Fish.Grade.FRESH:
			return fresh_fishes[index]
		Fish.Grade.PREMIUM:
			return premium_fishes[index]
		Fish.Grade.SUSHI:
			return sushi_fishes[index]
		_:
			assert(false, "invalid grade")
			return null

func get_score() -> int:
	match grade:
		Grade.LEFTOVERS:
			return 100
		Grade.FRESH:
			return 200
		Grade.PREMIUM:
			return 300
		Grade.SUSHI:
			return 500
		_: # This is also known as Unset Grade
			return 0

static func custom_sort_fish(a : Fish, b : Fish) -> bool:
	##Grade
	if a.grade > b.grade:
		return true
	elif b.grade > a.grade:
		return false
	
	##Name
	return a.fish_name < b.fish_name

func serialize() -> Array:
	var array : Array[Fish]
	match grade:
		Fish.Grade.LEFTOVERS:
			array = leftover_fishes
		Fish.Grade.FRESH:
			array = fresh_fishes
		Fish.Grade.PREMIUM:
			array = premium_fishes
		Fish.Grade.SUSHI:
			array = sushi_fishes
		_:
			assert(false, "invalid grade")
			array = []
	
	assert(array.has(self), "Illegal fish")
	return [grade,array.find(self)]

func grade_color() -> Color:
	match grade:
		Fish.Grade.LEFTOVERS:
			return Color.WHITE # Gray
		Fish.Grade.FRESH:
			return Color.GREEN # Green
		Fish.Grade.PREMIUM:
			return Color.PURPLE # Purple
		Fish.Grade.SUSHI:
			return Color.GOLD # Gold
		_:
			return Color.DIM_GRAY # Gray for Unset or unknown grades
