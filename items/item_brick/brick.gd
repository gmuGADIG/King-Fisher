class_name Brick
extends ThrowableItem


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not thrown:
		return
	print("AA1")
	if not body is Player:
		return
	if body == player:
		return
	
	var hitPlayer : Player = body
		##Does not take a fish if they are broke
	if hitPlayer.fish_inventory.is_empty():
		return
	
	##FIXME: There's a chance this runs numPlayers times, which is unintended
	Debug.log("I hit a guy, they have ",hitPlayer.fish_inventory)
	var target_fish : Fish
	if hitPlayer.has_ziplock_bag:
		var non_sushis : Array[Fish] = hitPlayer.fish_inventory.filter(
			func(fish : Fish) -> bool:
				return fish.grade != Fish.Grade.SUSHI
		)
		if non_sushis.is_empty():
			return
		target_fish = non_sushis.pick_random()
	else:	
		target_fish = hitPlayer.fish_inventory.pick_random()
	
	if target_fish == null:
		return
	var fish_to_remove : Array = target_fish.serialize()
	hitPlayer.take_fish_serialized.rpc(fish_to_remove)
