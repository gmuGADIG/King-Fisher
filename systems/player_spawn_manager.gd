extends Node3D

## SPAWN MANAGER
## This script looks for at least four player_spawn_point.tscn children. It spawns the players at them randomly.
## If a spawn point is occupied, it tries a different point.

var SpawnPoints: Array[Area3D]

func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			SpawnPoints.append(child)
			# Overengineering for fun. Deletes the Label3D that shows where the spawn point is to devs.
			# Delete these lines and the Label3D from the player_spawn_point.tscn scene if this is overkill.
			for grandchild in child.get_children():
				if grandchild is Label3D: grandchild.queue_free()


func get_safe_spawn_point() -> Vector3:
	SpawnPoints.shuffle()
	for spawnPoint in SpawnPoints:
		if spawnPoint.has_overlapping_bodies(): continue
		else: return spawnPoint.global_position
 
	Debug.log_err("get_safe_spawn_point did not find a safe spawn point.")
	return Vector3.ZERO
