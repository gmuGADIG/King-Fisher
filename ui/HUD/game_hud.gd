class_name GameHud
extends Control

@export var time_remaining_label : Label
@onready var active_buffs : Control = $ActiveBuffs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	if get_tree().current_scene.name != "Lobby":
		UIState.state_updated.connect(_ui_state_updated)

func _ui_state_updated(state : UIState.State) -> void:
	if state == UIState.State.LIVEWELL:
		hide()
	elif state == UIState.State.NONE:
		show()


func update_time(time : float) -> void:
	time_remaining_label.text = "Time Remaining:\n"+str("%.2f" % time)
