extends Node
class_name PlayerUtil

var player: Player

#Ragdoll Related
var ragdoll: PackedScene
var ragdolled := false

func _init(ply: Player) -> void:
	player = ply
	ragdoll = player.ragdoll

@rpc("reliable", "call_local")
func spawn_ragdoll(duration: float) -> void:
	if player.is_ragdolled(): return
	# Prep for ragdoll
	player.set_ragdolled(true)

	# Creates Ragdoll
	var new_ragdoll: Ragdoll = ragdoll.instantiate()
	player.add_sibling(new_ragdoll)
	new_ragdoll.position = player.global_position
	player.hide()

	# Timer before resetting
	await player.get_tree().create_timer(duration).timeout

	var ragdoll_pos := new_ragdoll.global_position

	# If player isn't on ground (water) then spawn at old position
	if player.is_on_floor():
		player.position = ragdoll_pos
	# Doesn't have an else since the player's position doesn't update unless they are on the floor through the code above.

	# Cleanup
	new_ragdoll.queue_free()
	player.show()
	player.set_ragdolled(false)

func is_ragdolled() -> bool: return player.ragdolled

func set_ragdolled(val: bool) -> void: player.ragdolled = val

func toggle_ragdoll() -> void: player.set_ragdolled(not player.is_ragdolled())

# Todo: Make it so that the function checks if the player is on actual ground
func is_valid_ground() -> bool: 
	return player.is_on_floor()
