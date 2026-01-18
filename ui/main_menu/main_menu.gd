extends Control


func _on_host_button_pressed() -> void:
	Multiplayer.create_server()
	print("Host Created")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")



func _on_connect_button_pressed() -> void:
	Multiplayer.join_server($VBoxContainer/JoinGame/IP.text)
	print("Lobby Joined")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")
