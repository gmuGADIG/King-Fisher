extends Item

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		# TODO: Implement animation once we have them.
		is_held = false
		(get_parent().get_parent() as Player).equip_helmet(self)
