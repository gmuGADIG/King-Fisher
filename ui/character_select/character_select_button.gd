extends TextureButton

signal character_selected(skin_index : int)
@export var skin_index : int


func _on_pressed() -> void:
	character_selected.emit(skin_index)
