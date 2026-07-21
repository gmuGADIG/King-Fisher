extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			return
		if Multiplayer.status != "":
			return
		CharacterSelect.open()
		


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		print("NEW HUMAN")
		if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			return
		CharacterSelect.close()
