extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			return
		print("player!")
		Tutorial.open()
		


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			return
		Tutorial.close()
