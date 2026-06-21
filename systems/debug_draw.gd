@tool
extends Control

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 10, Color.YELLOW)
