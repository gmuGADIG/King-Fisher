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
		
		var fishToRemoveName = hitPlayer.livewell.fish_inventory.keys().pick_random()
		# Current error: Invalid access to property or key '<null>' on a base object of type 'Dictionary[String, livewell_fish_info]'.
		#var fishToRemove: Fish = hitPlayer.livewell.fish_inventory[fishToRemoveName].fish
		
		print(hitPlayer.livewell.fish_inventory[fishToRemoveName])
		print(hitPlayer.livewell.fish_inventory[fishToRemoveName].fish)
		
		
		#steal_fish.rpc(fishToRemove, hitPlayer)
		
		print("hitPlayer.name = ", hitPlayer.name, "; player.name = ", player.name)

@rpc("authority", "call_local")
func steal_fish(fish: Fish, target: Player):
	target.livewell.removeFish(fish)
	player.livewell.addFish(fish)
