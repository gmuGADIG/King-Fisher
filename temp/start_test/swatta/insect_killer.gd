extends Area2D

@export var active := false

func _physics_process(_delta: float) -> void:
	if active:
		for area in get_overlapping_areas():
			if area is Insect:
				area.kill()
