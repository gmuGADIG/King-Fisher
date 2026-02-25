extends Node
class_name RagdollUtils

var player: Player

func _ready() -> void:
	assert(get_parent() is Player, "RagdollUtils needs to be a child of Player.")
	player = get_parent()

@rpc("reliable", "call_local")
func spawn_ragdoll(duration: float) -> void:
	if player.is_ragdolled: return
	player.is_ragdolled = true

	# Creates Ragdoll
	var new_ragdoll: Ragdoll = player.ragdoll.instantiate()
	player.add_sibling(new_ragdoll)
	new_ragdoll.position = player.global_position
	player.hide()

	# Timer before resetting
	await player.get_tree().create_timer(duration).timeout

	# TODO: test for if the player entered water

	# Cleanup
	new_ragdoll.queue_free()
	player.show()
	player.is_ragdolled = false
