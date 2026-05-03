extends Item

var duration = 10

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Ziplock bag used.")
		visible = false
		player.has_ziplock_bag = true
		$ZiplocUse.play()
		await get_tree().create_timer(duration).timeout
		player.has_ziplock_bag = false
		
		queue_free()
