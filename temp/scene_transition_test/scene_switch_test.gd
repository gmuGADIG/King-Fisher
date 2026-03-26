extends Node

#@export var packed_scene: PackedScene
@export_file("*.tscn") var file_scene: String

func _on_file_button_pressed() -> void:
	ScreenTransition.change_to_file(file_scene)
