extends Control

var playerRowScene = load("res://ui/scoreboard/player_row.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Call whenever a player joins or leaves the server.
func _updateScoreboardRowCount() -> void:
	# Remove previous rows
	for i in get_node("VBoxContainer").get_children():
		if i.is_in_group("Player Rows"):
			i.queue_free() 
	# Add a row for each player
	# for i in players:
		# var playerRowInstance = playerRowScene.instantiate()
		# get_node("VBoxContainer").add_child(playerRowInstance)
		# playerRowInstance.add_to_group("Player Rows")
		# (link the scoreboard row to the player here)
	pass
