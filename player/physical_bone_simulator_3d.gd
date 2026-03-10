extends PhysicalBoneSimulator3D

var player: Player
var skeleton: Skeleton3D

func _ready() -> void:
	player = $"../../../.."
	skeleton = get_parent()

# Called when the node enters the scene tree for the first time.
func ragdoll(duration: float) -> void:
	#physical_bones_start_simulation(["Head"])
	if player.is_ragdolled: return
	player.is_ragdolled = true
	physical_bones_start_simulation()
	$"Physical Bone Pelvis/PelvisCameraMount/RagdollCamera".current = true

	await player.get_tree().create_timer(duration).timeout

	physical_bones_stop_simulation()

	player.update_camera()
	player.is_ragdolled = false
	skeleton.reset_bone_poses()
