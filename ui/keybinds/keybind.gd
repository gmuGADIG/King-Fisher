extends Control

@export var binding_prototype: HBoxContainer

@onready var vbox: VBoxContainer = $KeybindPanel/ScrollContainer/VBoxContainer

var keybind_buttons: Dictionary[StringName, HBoxContainer]

var current_action: StringName
var current_button: Button

func _ready() -> void:
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action.begins_with("debug_"): continue
		var binding = binding_prototype.duplicate()
		var binding_label: Label = binding.get_node("Label")
		var binding_button: Button = binding.get_node("Button")
		binding_label.text = action
		binding_button.pressed.connect(_on_keybind_button_pressed.bind(action, binding_button))
		binding_button.text = InputMap.action_get_events(action)[0].as_text()
		keybind_buttons[action] = binding
		vbox.add_child(binding)
	binding_prototype.queue_free()

func _on_keybind_button_pressed(keybind: StringName, button: Button) -> void:
	button.text = "Listening..."
	current_action = keybind
	current_button = button

func _input(event: InputEvent) -> void:
	if current_action and event.is_action_type():
		InputMap.action_erase_events(current_action)
		InputMap.action_add_event(current_action, event)
		current_action = ""
		current_button.text = event.as_text()
		current_button.release_focus()
		current_button = null
	#else:  # Useful for checking if an input is bound to an action
		#for action in keybind_buttons.keys():
			#if (event.is_action(action)):
				#print("%s binds to %s!" % [event.as_text(), action])
