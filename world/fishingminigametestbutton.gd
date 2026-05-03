extends Button
@export_enum("UNSET", "LEFTOVERS", "FRESH", "PREMIUM", "SUSHI") var grade:int

signal test_cast(fish:Fish)

enum Grade{
	UNSET,
	LEFTOVERS,
	FRESH,
	PREMIUM,
	SUSHI,
}

func _on_pressed() -> void:
	var fish = Fish.new()
	fish.grade = grade
	emit_signal("test_cast", fish)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_cast"):
		_on_pressed()
