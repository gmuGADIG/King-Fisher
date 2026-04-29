class_name LobbyHUD
extends Control

static var instance: LobbyHUD

@export var countdownTimer_label : Label

func _init() -> void:
	instance = self
