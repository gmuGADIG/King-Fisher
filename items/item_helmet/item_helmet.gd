extends Item

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		# TODO: Implement animation once we have them.
		(get_parent() as Player).wearing_helmet = true
		queue_free()
