class_name LobbyHUD
extends Control

static var instance: LobbyHUD

@export var countdownTimer_label : Label
@onready var players_ready := $PlayersReady as Control
@onready var label_template := players_ready.get_node("Label") as Label
var ready_label_dict: Dictionary[int, Label]

func _init() -> void:
	instance = self

func add_player_ready(player_id: int, player_name: String) -> void:
	var player_label := label_template.duplicate() as Label
	player_label.text = "%s is ready!" % player_name
	player_label.show()
	players_ready.add_child(player_label)
	ready_label_dict[player_id] = player_label

func remove_player_ready(player_id: int) -> void:
	ready_label_dict[player_id].queue_free()
