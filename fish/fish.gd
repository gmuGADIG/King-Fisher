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

func _init() -> void:
	assert(grade != Grade.UNSET, "Please set the fish grade")
