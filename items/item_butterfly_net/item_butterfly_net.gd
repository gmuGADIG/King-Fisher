extends SwingableItem

# The butterfly net! This item steals a random fish from the victim's livewell.

## This function is connected to the item entering a body!
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	# The server is responsible for this function where RNG is handled.
	# The function will make an RPC call afterwards to synchronise the result.
	if !multiplayer.is_server(): return
	
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Doing something to %s!" % body.name)
		var hitPlayer: Player = body
		
		##FIXME: There's a chance this runs numPlayers times, which is unintended
		##Also FIXME: Resources are not serializable
		var fish_to_remove = hitPlayer.fish_inventory.pick_random()
		hitPlayer.take_fish.rpc(fish_to_remove)
		holder.give_fish.rpc(fish_to_remove)
