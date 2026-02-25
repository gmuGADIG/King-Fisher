extends Node3D

##Controls the speed at which the player turns. The domain is measured in radian angle difference, and the value is measured in radians per second
@export var rotation_speed_curve : Curve

func turn_towards(target_direction : Vector2, delta : float) -> void:
	var angle = angle_difference(rotation.y,-target_direction.angle())
	var rotation_speed : float = delta * rotation_speed_curve.sample(abs(angle))
	angle = clampf(angle,-rotation_speed,rotation_speed)
	rotation.y += angle
