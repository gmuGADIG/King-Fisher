extends Node

@onready var anim: AnimationPlayer = $AnimationPlayer

func change_to_packed(packed: PackedScene):
	anim.play("loading")
	await anim.animation_finished
	get_tree().change_scene_to_packed(packed)

func change_to_file(path: String):
	anim.play("loading")
	await anim.animation_finished
	get_tree().change_scene_to_file(path)
