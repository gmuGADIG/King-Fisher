extends Node
class_name countdownLobbyTimer

var time = 5
func _process(delta):
	time -= delta


func getTime():
	return time
