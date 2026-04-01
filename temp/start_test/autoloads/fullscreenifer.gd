extends Node

@onready var window := get_window()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
