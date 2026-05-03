class_name ResultsScreen
extends Node3D

# can be 1, 2, 3, or 4
static var place = 1

@onready var label: Label = %PlacementLabel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	match place:
		1: label.text = "1st place"
		2: label.text = "2nd place"
		3: label.text = "3rd place"
		4: label.text = "4th place"

func _on_continue_button_pressed() -> void:
	SceneTransition.change_to_file("res://world/lobby/lobby.tscn")

