extends Control
@export var countdownTimer_label : Label

var countdownTimer : countdownLobbyTimer

func _process(delta):
	update_countdownTimer_label()
	
func update_countdownTimer_label():
	countdownTimer_label.text = countdownTimer.getTime()
