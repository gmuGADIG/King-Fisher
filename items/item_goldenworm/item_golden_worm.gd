extends Item

var duration = 10

## The generic use function. You can write your own in a class that extends Item.
func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Golden Worm used.")
		visible = false
		(get_parent() as Player).golden_worm_active = true
		await get_tree().create_timer(duration).timeout
		(get_parent() as Player).golden_worm_active = false
		Debug.log("Golden Worm deleted.")
		queue_free()
