extends ThrowableItem
@export var slow_time : float = 50
@export_range(0.0, 1.0, 0.01) var slow_amount : float = 0.4
@export var glue_icon : Texture

func _on_land() -> void:
	$GPUParticles3D.emitting = true
	var hit_players = get_overlapping_bodies()
	for hit_player in hit_players:
		Debug.log("p = %s; player = %s" % [hit_player, player])
		if hit_player is Player:
			Debug.log("hit player")
			hit_player.slow(slow_time, slow_amount)
			hit_player.add_item_buff("Glue",slow_time,glue_icon)
	await get_tree().create_timer(0.5).timeout
	queue_free()
