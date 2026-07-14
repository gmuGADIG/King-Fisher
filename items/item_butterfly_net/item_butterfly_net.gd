class_name FishingNet
extends SwingableItem

# The butterfly net! This item steals a random fish from the victim's livewell.

#func _ready() -> void:
	#super._ready()
## This function is connected to the item entering a body!
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	Debug.log("Fishing net hit")
	# The server is responsible for this function where RNG is handled.
	# The function will make an RPC call afterwards to synchronise the result.
	if !multiplayer.is_server(): return
	
	if is_held and body.is_in_group("Player") and body != holder:
		if get_node_or_null("HitSound"):
			$HitSound.play()
		Debug.log("Doing something to %s!" % body.name)
		var hitPlayer: Player = body
		
		
		##FIXME: There's a chance this runs numPlayers times, which is unintended
		##Also FIXME: Resources are not serializable
		Debug.log("I hit a guy, they have ",hitPlayer.fish_inventory)
		var target_fish : Fish
		if hitPlayer.has_ziplock_bag:
			target_fish = hitPlayer.fish_inventory.filter(
				func(fish : Fish) -> bool:
					return fish.grade != Fish.Grade.SUSHI
			).pick_random()
		else:	
			target_fish = hitPlayer.fish_inventory.pick_random()
		
		if target_fish == null:
			return
		var fish_to_remove : Array = target_fish.serialize()
		hitPlayer.take_fish_serialized.rpc(fish_to_remove)
		player.give_fish_serialized.rpc(fish_to_remove)
