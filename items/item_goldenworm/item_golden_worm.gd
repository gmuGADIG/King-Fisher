extends Item 
@onready var audio_player : AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var duration = 10
@export var buff_texture : Texture2D

## The generic use function. You can write your own in a class that extends Item.
func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Golden Worm used.")
		visible = false
		audio_player.bus = "SFX"
		audio_player.play()
		player.golden_worm_active = true
		player.add_item_buff("Golden Worm", duration, buff_texture)
		await get_tree().create_timer(2.25).timeout
		#player.golden_worm_active = false
		##player.remove_item_buff("Golden Worm")
		Debug.log("Golden Worm deleted.")
		queue_free()
