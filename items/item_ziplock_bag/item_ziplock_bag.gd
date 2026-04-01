extends Item

var duration = 10

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Ziplock bag used.")
		visible = false
		(get_parent() as Player).has_ziplock_bag = true
		await get_tree().create_timer(duration).timeout
		(get_parent() as Player).has_ziplock_bag = false
		Debug.log("Ziplock bag deleted.")
		queue_free()
