extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not visible:
			pause()
		else:
			_on_continue_pressed()

func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true

func _on_continue_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false


func _on_quit_pressed() -> void:
	Multiplayer.disconnect_from_game()
	visible = false
