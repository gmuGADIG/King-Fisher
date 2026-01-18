extends Control


func _on_host_button_pressed() -> void:
	MultiplayerBus.create_server()
	print("Host Created")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")



func _on_connect_button_pressed() -> void:
	print("Lobby Joined")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")
