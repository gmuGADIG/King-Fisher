extends Node2D

var pulse_tween : Tween

func _on_rhythm_engine_beat() -> void:
	pulse_tween = create_tween()
	pulse_tween.tween_property(	
		self, "global_scale", Vector2.ONE, 0.1
	).from(Vector2(2,2))
