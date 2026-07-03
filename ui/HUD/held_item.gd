class_name HeldItemUI extends Control

@onready var held_item_root = %ItemRoot

func _ready() -> void:
	clear_item()
	print("Hide")
	
	if get_tree().current_scene.name == "Lobby":
		modulate = Color(0,0,0,0)
	else:
		UIState.state_updated.connect(_ui_state_updated)
	
func _ui_state_updated(state : UIState.State) -> void:
	if state == UIState.State.LIVEWELL:
		hide()
	elif state == UIState.State.NONE:
		show()

func hold_item(item_name: String) -> void:
	clear_item()
	if held_item_root.has_node(item_name):
		held_item_root.get_node(item_name).visible = true
	else:
		print("Cannot find the item named %s!" % item_name)

func clear_item() -> void:
	for item in held_item_root.get_children():
		item.visible = false
