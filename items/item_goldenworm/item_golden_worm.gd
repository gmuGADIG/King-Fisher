extends Item 
var duration = 10
@onready var audio_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

## The generic use function. You can write your own in a class that extends Item.
func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Golden Worm used.")
		visible = false
		audio_player.bus = "SFX"
		audio_player.play()
		player.golden_worm_active = true
		player.livewell.add_buff("Golden Worm")
		await get_tree().create_timer(duration).timeout
		player.golden_worm_active = false
		player.livewell.remove_buff("Golden Worm")
		Debug.log("Golden Worm deleted.")
		queue_free()
