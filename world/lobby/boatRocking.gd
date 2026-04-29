extends Node3D

var left = true

var clock: float = 0
func _process(delta: float) -> void:
	clock += delta
	rotation.x = remap(sin(clock/1.33), -1, 1, -.01, .01)
	rotation.z = remap(sin(clock/1.7), -1, 1, -.025, .025)
	position.y = remap(sin(clock/1.5), -1, 1, 0.15, 1.5)
