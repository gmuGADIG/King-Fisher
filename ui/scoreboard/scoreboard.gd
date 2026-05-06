extends Control

var players = [] # These two arrays have parity because godot doesn't support nested collections :')
var playerRows = [] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await (all players loaded) # This is a cleaner solution than reseting the leaderboard every update
	#_updateScoreboardRowCount()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#visible = Input.is_action_pressed("scoreboard")
	#if (visible):
		#_updateScoreboardRowCount()

# Call after all players load into a round.
func _updateScoreboardRowCount() -> void:
	# Remove previous rows
	for i in get_node("VBoxContainer").get_children():
		if i.is_in_group("Player Rows"):
			i.queue_free() 
	
	# Clear arrays
	players = []
	playerRows = []
	
	players = get_tree().get_nodes_in_group("Player")
	var count = 0
	# Add a row for each player
	for i in players:
		var playerRowScene = load("res://ui/scoreboard/player_row.tscn")
		var playerRowInstance = playerRowScene.instantiate()
		get_node("VBoxContainer").add_child(playerRowInstance)
		playerRowInstance.add_to_group("Player Rows")
		playerRows.append(playerRowInstance)
		count += 1
	_updateScoreboard()
	pass

# Only updates the data of rows, not the number of rows
func _updateScoreboard() -> void:
	for i in range(get_tree().get_nodes_in_group("Player").size()):
		var row = playerRows[i]
		var livewell = players[i].get_node("LivewellMenu")
		row.get_node("ScoreLabel").text = str(livewell.intScore)
		row.get_node("FishCountLabel").text = str(livewell.livewellInventory.size())
		# Calculate sushi-grade fish count
		var sushiCount = 0
		for j in livewell.livewellInventory:
			if j != null:
				if j.grade == Fish.Grade.SUSHI:
					sushiCount += 1
		row.get_node("SushiCountLabel").text = str(sushiCount)
		# Set player name here
