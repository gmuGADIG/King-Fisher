extends Control

@export var binding_prototype: HBoxContainer

@onready var vbox: VBoxContainer = $KeybindPanel/VBoxContainer

var keybind_buttons: Dictionary[StringName, HBoxContainer]

func _ready() -> void:
	for action in InputMap.get_actions():
		var binding = binding_prototype.duplicate()
		var binding_label: Label = binding.get_node("Label")
		var binding_button: Button = binding.get_node("Button")
		binding_label.text = action
		binding_button.pressed.connect(_on_keybind_button_pressed.bind(action))
		binding_button.text = InputMap.action_get_events(action)[0].as_text()
		keybind_buttons[action] = binding
		vbox.add_child(binding)
	binding_prototype.queue_free()

func _on_keybind_button_pressed(keybind: StringName) -> void:
	pass
