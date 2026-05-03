extends Area3D
class_name FishShadow



var id : int
var currently_fishing : bool
var fish : Fish


func _ready() -> void:
	$AnimationPlayer.play("fish_spin")

@rpc("any_peer","reliable","call_local")
static func current_fishing_state(id : int, state : bool) -> void:
	var shadow : FishShadow = WorldGameplay.fish_shadows[id]
	assert(shadow != null,"phantom fish")
	shadow.currently_fishing = state

@rpc("any_peer","reliable","call_local")
static func kill_fish_shadow(id : int) -> void:
	var shadow : FishShadow = WorldGameplay.fish_shadows[id]
	assert(shadow != null,"not real fish")
	WorldGameplay.fish_shadows.erase(id)
	shadow.queue_free()
