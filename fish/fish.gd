extends Resource
class_name Fish

enum Grade{
	UNSET,
	LEFTOVERS,
	FRESH,
	PREMIUM,
	SUSHI,
}

@export var fish_name : String
@export var grade : Grade
@export var sprite : Texture
@export var description : String

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
