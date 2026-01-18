extends Control

@onready var name_text := $DisplayName/NameInput

func _on_host_button_pressed() -> void:
	#if name_text.text.length() == 0:
		#name_text.text = "Player"+str(randi_range(1,999))
	Multiplayer.create_server()
	print("Host Created")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")



func _on_connect_button_pressed() -> void:
	Multiplayer.join_server($VBoxContainer/JoinGame/IP.text)
	print("Lobby Joined")
	get_tree().change_scene_to_file("res://temp/temp_lobby/temp_lobby.tscn")
