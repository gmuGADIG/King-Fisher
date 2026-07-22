extends Control

@export var scoreboard_row_packed : PackedScene

var players = [] # These two arrays have parity because godot doesn't support nested collections :')
var playerRows = [] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##Create the correct number of rows
	for player_id in Multiplayer.player_list:
		var new_player_score : ScoreboardRow = scoreboard_row_packed.instantiate()
		new_player_score.setup(player_id)
		$BackPanel/VBoxContainer/Players.add_child(new_player_score)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scoreboard") and not UIState.more_ui_blocked:
		show()
	elif event.is_action_released("scoreboard"):
		hide()
