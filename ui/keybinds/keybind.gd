class_name Keybinds
extends Control

@export var binding_prototype: HBoxContainer

@onready var vbox: VBoxContainer = $KeybindPanel/ScrollContainer/VBoxContainer

var keybind_buttons: Dictionary[StringName, HBoxContainer]

var current_action: StringName
var current_button: Button

func _ready() -> void:
	load_keybinds()
	reflow_ui()

func reflow_ui() -> void:
	binding_prototype.visible = true
	for item in keybind_buttons:
		keybind_buttons[item].queue_free()
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action.begins_with("debug_"): continue
		var binding = binding_prototype.duplicate()
		var binding_label: Label = binding.get_node("Label")
		var binding_button: Button = binding.get_node("Button")
		binding_label.text = action.capitalize()
		binding_button.pressed.connect(_on_keybind_button_pressed.bind(action, binding_button))
		binding_button.text = InputMap.action_get_events(action)[0].as_text().replace(' - Physical', '')
		keybind_buttons[action] = binding
		vbox.add_child(binding)
	binding_prototype.visible = false

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
		save_keybinds()
	#else:  # Useful for checking if an input is bound to an action
		#for action in keybind_buttons.keys():
			#if (event.is_action(action)):
				#print("%s binds to %s!" % [event.as_text(), action])

## Saves the currently configured keybinds to the user's local data directory.
func save_keybinds() -> void:
	print("saving")
	var keybind_dict: Dictionary[StringName, InputEvent]
	for action in keybind_buttons.keys():
		keybind_dict[action] = InputMap.action_get_events(action)[0]
	var save_file = FileAccess.open("user://keybinds.cfg", FileAccess.WRITE)
	save_file.store_var(keybind_dict, true)

## Loads the previously saved keybinds.
## If a saved file exists and the keybinds are loaded successfully, returns true.
## Otherwise, returns false.
static func load_keybinds() -> void:
	var save_file = FileAccess.open("user://keybinds.cfg", FileAccess.READ)
	if save_file:
		var keybind_dict: Dictionary[StringName, InputEvent] = save_file.get_var(true)
		for action in keybind_dict:
			print(keybind_dict[action].as_text())
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keybind_dict[action])
		print("KEYBINDS LOADED")

func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	reflow_ui()
	save_keybinds()
