extends CanvasLayer

var old_mouse_mode: Input.MouseMode

func open_debug_menu() -> void:
	old_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

func close_debug_menu() -> void:
	hide()
	Input.mouse_mode = old_mouse_mode

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		if visible:
			close_debug_menu()
		else:
			open_debug_menu()

func _on_close_button_pressed() -> void:
	close_debug_menu()
