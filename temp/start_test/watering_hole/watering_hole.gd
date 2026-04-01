class_name WateringHole
extends Area2D

@onready var fill_timer: Timer = %FillTimer

func _on_area_entered(area: Area2D) -> void:
	if area is Watercan:
		fill_timer.start()

func _on_area_exited(area: Area2D) -> void:
	if area is Watercan:
		fill_timer.stop()

func _on_fill_timer_timeout() -> void:
	Watercan.instance.contained_water += 1
