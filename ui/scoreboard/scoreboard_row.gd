class_name ScoreboardRow
extends HBoxContainer

var player_id : int = -1

var last_fish_count : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set playerName to the correct player's name
	pass # Replace with function body.

func setup(player_id : int) -> void:
	self.player_id = player_id
	%PlayerLabel.text = Multiplayer.player_list[player_id].playerName
	%ScoreLabel.text = str(0,"¤")
	%FishCountLabel.text = str(0)
	%SushiCountLabel.text = str(0)
	last_fish_count = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player_id == -1:
		return
	
	var player_instance : Player = Multiplayer.player_list[player_id].player
	if player_instance == null:
		return
	
	var new_fish_count : int = player_instance.get_fish_count()
	if last_fish_count == new_fish_count:
		return
	
	
	%ScoreLabel.text = str(player_instance.score,"¤")
	%FishCountLabel.text = str(new_fish_count)
	%SushiCountLabel.text = str(player_instance.get_sushi_count())
	last_fish_count = new_fish_count
