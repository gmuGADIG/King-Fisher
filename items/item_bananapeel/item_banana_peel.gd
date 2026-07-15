class_name BananaPeel
extends ThrowableItem

static var armadillo_mode : bool = false

var hit_ground : bool
@export var ragdollTime : float = 1.0

func _ready() -> void:
	if armadillo_mode:
		%BANANNA2.hide()
		%Armadillo.show()
	else:
		%BANANNA2.show()
		%Armadillo.hide()
	super._ready()

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
		body.ragdoll_phys.ragdoll(ragdollTime, true)
		## TODO: DELETE THIS HORRIBLE REPARENTING
		var node = $BananaSlipSound
		var parent = node.get_parent()
		var grandparent = parent.get_parent()

		var global_transform = node.global_transform
		node.reparent(grandparent)
		node.global_transform = global_transform
		node.play()
		queue_free()

@rpc("reliable","call_local","authority")
static func set_armadillo_mode(val : bool) -> void:
	armadillo_mode = val
