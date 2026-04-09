extends ThrowableItem
var hit_ground : bool
@export var ragdollTime : float = 1.0

func _on_land() -> void:
	hit_ground = true
	pass
	
##func _on_body_entered(body: Node3D) -> void:
	## Items don't care about collisions if they're from non-players or if the item is already held.
	##if(!hit_ground):
		##if is_held || !body.is_in_group("Player"): return
		#if body.has_method("pick_up_item"): 
			#item_got_picked_up.emit()
			## We call deferred because this is physics and getting picked up involves reparenting.
			## No fucking with the scene tree before physics is done happening!
			#body.pick_up_item.call_deferred(self)
	#else:
		#if !body.is_in_group("Player"): return
		#if body.has_method("ragdoll"):
			#body.ragdoll
			#queue_free()
			#pass


func on_player_collide(body: Node3D) -> void:
	if(hit_ground && body is Player):
		var ragdoll = body.get_node("Body/Armature/Skeleton3D/Bones")
		ragdoll.ragdoll(ragdollTime,true)
		queue_free()
