extends SwingableItem

@export var ragdollTime : float = 1.0

# The mallet, causing a player to be ragdolled

## This function is connected to the item entering a body!
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Doing something to %s!" % body.name)
		var hitPlayer: Player = body
		body.ragdoll_phys.ragdoll(ragdollTime, true)
		visible = false;
		print("HAMMER hitPlayer.name = ", hitPlayer.name, "; player.name = ", player.name)
