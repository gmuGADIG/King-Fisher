class_name WaterDrop
extends Area2D

signal became_vulnrable

@export var amount := 5.0

# gravity is already used by Area2D????
@export var accel := 700
var velocity := 100.0

@export var invulnrability_time := .65:
	set(v):
		if not vulnrable and v <= 0:
			became_vulnrable.emit()
		
		invulnrability_time = v

var vulnrable: bool:
	get:
		return invulnrability_time <= 0

func _process(delta: float) -> void:
	if not vulnrable:
		invulnrability_time -= delta

func _physics_process(delta: float) -> void:
	velocity += accel * delta
	position += Vector2.DOWN * velocity * delta
