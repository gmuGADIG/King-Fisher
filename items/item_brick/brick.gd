class_name Brick
extends ThrowableItem


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body is Player) and body != player:
		body.remove_random_fish()
