extends CanvasLayer

## The amount of time it takes to fade in and out
@export var fade_time : float = 0.75

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var loading_screen : ColorRect = $ColorRect


func change_to_packed(packed: PackedScene):
	loading_screen.modulate.a = 0
	loading_screen.visible = true
	anim.play("loading")
	##Fade out of scene
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(loading_screen,"modulate:a",1.0,fade_time)
	await tween.finished
	##Wait for scene to load
	
	await anim.animation_finished
	## Fade into scene
	get_tree().change_scene_to_packed(packed)
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(loading_screen,"modulate:a",0.0,fade_time)
	await tween.finished
	loading_screen.modulate.a = 0
	loading_screen.visible = false
	anim.stop()
	
	

func change_to_file(path: String):
	change_to_packed(load(path))
