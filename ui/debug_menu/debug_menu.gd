extends CanvasLayer

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		print("Debug!")
		visible = not visible

func _on_close_button_pressed() -> void:
	hide()
