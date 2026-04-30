extends ThrowableItem
@export var slow_time : float
@export var slow_amount : float


func _on_area_3d_body_entered(body: Node3D) -> void:
	var players = get_overlapping_bodies()
	Debug.log(player)
	for p in players:
		#Debug.log("p = %s; player = %s" % [p, player])
		if (p is Player) and p != player  :
			#$GPUParticles3D.emitting = true
			Debug.log("hit player")
			p.slow(50,0.2)
			queue_free()
