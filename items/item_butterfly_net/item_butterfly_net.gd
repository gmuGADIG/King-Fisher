extends SwingableItem

# The butterfly net! This item steals a random fish from the victim's livewell.

## This function is connected to the item entering a body!
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Doing something to %s!" % body.name)
		var hitPlayer: Player = body
		var fish := hitPlayer.livewell.removeFish()

		if fish != null:
			player.livewell.addFish(fish)

		print("hitPlayer.name = ", hitPlayer.name, "; player.name = ", player.name)
