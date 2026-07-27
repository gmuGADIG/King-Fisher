class_name PlayerMesh
extends Node3D

##Controls the speed at which the player turns. The domain is measured in radian angle difference, and the value is measured in radians per second
@export var mesh : MeshInstance3D
@export var rotation_speed_curve : Curve
@export var bones : PhysicalBoneSimulator3D

@onready var fish_dummy : Sprite3D = $FishReelIn

func turn_towards(target_direction : Vector2, delta : float) -> void:
	var angle = angle_difference(rotation.y,-target_direction.angle())
	var rotation_speed : float = delta * rotation_speed_curve.sample(abs(angle))
	angle = clampf(angle,-rotation_speed,rotation_speed)
	rotation.y += angle

@rpc("reliable","any_peer","call_local")
func fish_reel_in(fish_shadow_id : int) -> void:
	var shadow : FishShadow = WorldGameplay.fish_shadows[fish_shadow_id]
	fish_dummy.global_position = shadow.global_position
	fish_dummy.texture = shadow.fish.sprite
	fish_dummy.show()
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(fish_dummy,"position",Vector3(0,2.753,0),0.4).set_ease(Tween.EASE_IN)
	await tween.finished
	$FishReelIn/ReelIn.play("reel")
	#tween.tween_property(fish_dummy,"position",Vector3(0,2.327,-1.113),0.3).set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(fish_dummy,"position",Vector3(0,1.256,-0.161),0.3).set_ease(Tween.EASE_OUT_IN)
