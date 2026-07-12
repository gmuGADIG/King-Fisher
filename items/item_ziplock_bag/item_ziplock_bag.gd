class_name ZiplockBag
extends Item

@export var duration : float = 10
@export var buff_texture : Texture

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Ziplock bag used.")
		visible = false
		player.set_has_ziplock.rpc(true)
		$ZiplocUse.play()
		player.add_item_buff("Ziplock Bag", duration, buff_texture)
		await get_tree().create_timer(1.0).timeout
		queue_free()
