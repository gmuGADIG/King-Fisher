extends SwingableItem

# The butterfly net! This item steals a random fish from the victim's livewell.

func use():
	if !is_held: Debug.log_err("Something is wrong")
	else:
		holder = get_parent_node_3d()
		Debug.log("Swing swing swing")
		area_entered.connect(effect_on_contact)
		position += Vector3.FORWARD
		spin = create_tween().set_parallel()
		spin.tween_property(
			holder.get_node("Body"), "rotation_degrees:y", 360, 0.4
		).as_relative().set_ease(Tween.EASE_OUT)
		# TODO: tween the item to spin around
		spin.finished.connect(queue_free)

## This function is connected to the item entering a body!p
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Doing something to %s!" % body.name)
		var hitPlayer: Player = body
		var fishIndexToTake: int = randi_range(1, hitPlayer.livewell.livewellInventory.size)-1
		var fishToTake: Fish = hitPlayer.livewell.livewellInventory[fishIndexToTake]
		hitPlayer.take_fish(fishToTake)
