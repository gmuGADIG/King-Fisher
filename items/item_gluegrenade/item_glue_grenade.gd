extends ThrowableItem
@export var slow_time : float
@export var slow_amount : float


func _on_area_3d_body_entered(body: Node3D) -> void:
	var players = get_overlapping_bodies()
	Debug.log(player)
	for player in players:
		if(player is Player):
			Debug.log("hit player")
			player.slow(0.5,5.0)
	queue_free()
