extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if UIState.more_ui_blocked and UIState.ui_state != UIState.State.PAUSE:
			return
			
		if not visible:
			pause()
		else:
			unpause()

func pause() -> void:
	UIState.ui_state = UIState.State.PAUSE
	visible = true


func unpause() -> void:
	UIState.ui_state = UIState.State.NONE
	visible = false


func _on_quit_pressed() -> void:
	Multiplayer.disconnect_from_game()
	visible = false
