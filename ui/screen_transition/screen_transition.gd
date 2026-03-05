extends CanvasLayer

## The amount of time it takes to fade in and out
@export var fade_time : float = 0.75

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var loading_screen : ColorRect = $ColorRect

var m_path : String
var process : Array

func _process(delta: float) -> void:
	var loadStatus := ResourceLoader.load_threaded_get_status(m_path, process)
	if(loadStatus != 0):
		print(loadStatus)
	

func change_to_packed(path: String):
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
	ResourceLoader.load_threaded_request(path)
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
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
