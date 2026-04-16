extends SwingableItem

#The Rubbermallet will ragdoll other players when they are hit

## This function is connected to the item entering a body!
## If the item is held, and the body entered is not the holder,
## knock them down
func effect_on_contact(body: Node3D):
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Knocking down %s!" % body.name)
		var hitPlayer: Player = body
		hitPlayer.ragdoll_phys.ragdoll(2)
		print("hitPlayer.name = ", hitPlayer.name, "; player.name = ", player.name)
