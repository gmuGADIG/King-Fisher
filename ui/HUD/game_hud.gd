class_name GameHud
extends Control

@export var score_changed_label_packed : PackedScene

@export var time_remaining_label : Label
@onready var active_buffs : Control = %ActiveBuffs

@onready var score_change_location : Vector2 = $ButtomPrompts/HBoxContainer/VBoxContainer2/ColorRect/ScoreChangeLocation.global_position

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

func show_score_change(score : int) -> void:
	print("Showing score change")
	var new_score_changed_label : ScoreChangedLabel = score_changed_label_packed.instantiate()
	new_score_changed_label.text = str("+",score,"¤") if score > 0 else str(score,"¤")
	#new_score_changed_label.position = score_change_location
	$ButtomPrompts/HBoxContainer/VBoxContainer2/ColorRect/ScoreChangeLocation.add_child(new_score_changed_label)
	new_score_changed_label.rise()
