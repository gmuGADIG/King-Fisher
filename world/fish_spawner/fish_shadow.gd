extends Area3D
class_name FishShadow

var id : int
var currently_fishing : bool
var fish : Fish:
	set(val):
		fish = val
		if fish != null:
			set_grade_particle(fish)

@export var cpu_particle : CPUParticles3D

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


func set_grade_particle(fish : Fish) -> void:
	match fish.grade:
		Fish.Grade.UNSET, Fish.Grade.LEFTOVERS, Fish.Grade.FRESH, Fish.Grade.PREMIUM:
			cpu_particle.color = fish.grade_color()
		Fish.Grade.SUSHI:
			cpu_particle.color = fish.grade_color()
			#particle.color_initial_ramp = load("res://fish/sushi/sushi_gradient.tres")
			pass
			#return fresh_particle
		_:
			assert(false,"invalid grade")
