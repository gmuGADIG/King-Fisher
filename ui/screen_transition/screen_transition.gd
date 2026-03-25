extends CanvasLayer

## The amount of time it takes to fade in and out
@export var fade_time : float = 0.75

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var loading_screen : ColorRect = $ColorRect

var m_path : String

func change_to_packed(path: String):
	loading_screen.modulate.a = 0
	loading_screen.visible = true
	anim.play("loading")

	##Fade out of scene
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(loading_screen,"modulate:a",1.0,fade_time)
	await tween.finished

	# load scene during animation
	ResourceLoader.load_threaded_request(path)
	var progress : Array = []
	var loadStatus := ResourceLoader.load_threaded_get_status(path, progress)
	while loadStatus != ResourceLoader.THREAD_LOAD_LOADED:
		loadStatus = ResourceLoader.load_threaded_get_status(path, progress)
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))

	# wait for animation to end
	if anim.is_playing():
		await anim.animation_finished

	## Fade into scene
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(loading_screen,"modulate:a",0.0,fade_time)

	await tween.finished

	loading_screen.modulate.a = 0
	loading_screen.visible = false
	anim.stop()

func change_to_file(path: String):
	m_path = path
	change_to_packed(path)
