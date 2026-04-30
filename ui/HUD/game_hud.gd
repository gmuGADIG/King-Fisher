class_name GameHud
extends Control

@export var time_remaining_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func update_time(time : float) -> void:
	time_remaining_label.text = "Time Remaining:\n"+str("%.2f" % time)
