extends Area3D
class_name FishShadow

@export var partical_mat : StandardMaterial3D

var id : int
var currently_fishing : bool
var fish : Fish:
	set(val):
		fish = val
		if fish != null:
			$CPUParticles3D.mesh = fish.grade_particle()


func _ready() -> void:
	$AnimationPlayer.play("fish_spin")

@rpc("any_peer","reliable","call_local")
func current_fishing_state(state : bool) -> void:
	Debug.log("I am having my fish state changed")
	currently_fishing = state

@rpc("any_peer","reliable","call_local")
func kill_fish_shadow() -> void:
	WorldGameplay.fish_shadows.erase(id)
	queue_free()
