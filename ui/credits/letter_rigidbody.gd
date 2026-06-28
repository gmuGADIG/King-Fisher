class_name LetterRigid
extends RigidBody2D

@export var collision_shape : CollisionShape2D
@export var letter : Label

@export var random_angular : float
@export var random_linear : Vector2

func _ready() -> void:
	linear_velocity.y = randf_range(
		-random_linear.y,random_linear.y
	)
	linear_velocity.x = randf_range(
		-random_linear.x,random_linear.x
	)
	angular_velocity = randf_range(
		-random_angular,random_angular
	)
