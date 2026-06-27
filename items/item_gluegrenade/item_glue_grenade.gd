extends ThrowableItem
@export var slow_time : float = 50
@export_range(0.0, 1.0, 0.01) var slow_amount : float = .4

var active := false

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if not active : return
	var players = get_overlapping_bodies()
	for p in players:
		Debug.log("p = %s; player = %s" % [p, player])
		if (p is Player) and (p != player):
			#$GPUParticles3D.emitting = true
			Debug.log("hit player")
			p.slow(slow_time, slow_amount)
			queue_free()

func pre_throw() -> void:
	$GPUParticles3D.emitting = true
	active = true
