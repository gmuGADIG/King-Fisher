class_name Radios
extends Node2D

func get_value() -> int:
	for idx in get_child_count():
		if (get_child(idx) as RadioButton).selected:
			return idx
	return -1

func set_value(value: int) -> void:
	for radio_button: RadioButton in get_children():
		radio_button.selected = false
	get_child(value).selected = true
