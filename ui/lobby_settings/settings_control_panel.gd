extends Area3D

@export var lobby_settings_menu : LobbySettings

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if not multiplayer.is_server():
			return
		if not body.is_multiplayer_authority():
			return
		lobby_settings_menu.open()
		


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		if not multiplayer.is_server():
			return
		lobby_settings_menu.close()
