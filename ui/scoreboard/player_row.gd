extends HBoxContainer

var playerName = "" # probably will be used to determine which player this row belongs to


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set playerName to the correct player's name
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%PlayerLabel.text = playerName
	# %ScoreLabel.text = get player score
	# %FishCountLabel.text = get player fish count
	# %SushiCountLabel.text = get player sushi count
