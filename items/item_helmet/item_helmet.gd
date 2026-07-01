extends Item

@export var helmet_icon : Texture

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		# TODO: Implement animation once we have them.
		is_held = false
		player.equip_helmet(self)
		player.add_item_buff("Helmet",-1,helmet_icon)
