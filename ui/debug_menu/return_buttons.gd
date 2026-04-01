extends Button

@export_file_path("*.tscn") var scene_path

func _ready() -> void:
	pressed.connect(func():
		ScreenTransition.change_to_file(scene_path)
		DebugMenu.close_debug_menu()
		Multiplayer.disconnect_from_game()
	)
