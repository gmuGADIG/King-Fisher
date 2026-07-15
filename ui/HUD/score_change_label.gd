class_name ScoreChangedLabel
extends Label

@export var rise_distance : float = 50.0
@export var rise_time : float = 5.0

func rise() -> void:
	print("rising")
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel()
	tween.tween_property(self,"position:y",position.y-rise_distance,rise_time)
	tween.tween_property(self,"modulate:a",0,rise_time)
	await tween.finished
	queue_free()
