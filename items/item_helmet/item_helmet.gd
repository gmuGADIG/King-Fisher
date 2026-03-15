extends Item

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		# Todo: Impliment animation once we have them.
		get_parent().items.helmet = true
		queue_free()
