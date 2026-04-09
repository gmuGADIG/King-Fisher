extends Control

var livewellInventory = []
@export var currentFish : String
@onready var livewellPanel : Panel = $Panel
@onready var fish : Label = $Panel/VBoxContainer/Fish
@onready var score : Label = $Panel/VBoxContainer/Score
@onready var sprites : TextureRect = $Panel/VBoxContainer/Score/TextureRect
@onready var fishCount : Label = $Panel/VBoxContainer/Score/TextureRect/fishCount
var intScore : int = 0;

func _ready() -> void:
	hide()

func changeScore(change : int):
	intScore += change
	score.text = "Score " + str(intScore)
	updateVisual()

func addFish(newFish : Fish) -> void:
	livewellInventory.append(newFish)
	changeScore(100)
	updateVisual()

func removeFish() -> void:
	if(livewellInventory.size() == 0):
		return
	
	# Max here. Editing this function, Kaiden says by default this should take a random fish.
	var fishIndexToTake: int = randi_range(1, livewellInventory.size())-1
	livewellInventory.remove_at(fishIndexToTake)
	
	sprites.texture = null
	changeScore(-100)
	if(intScore < 0):
		changeScore(100)
	updateVisual()
	
func updateVisual() -> void:
	currentFish = ""
	for printFish in livewellInventory:
		var gradeType = 0
		if(printFish.grade == printFish.Grade.SUSHI):
			gradeType += 1
			sprites.texture = printFish.sprite
		currentFish = currentFish + printFish.fish_name + " (" + str(gradeType) + ")\n"  
	fish.text = currentFish
	if(!livewellInventory.size()):
		fishCount.text = ""
	else:
		fishCount.text = "x" + str(livewellInventory.size())
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		visible = !visible
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/sushi/test_fish.tres")
		addFish(newFish)
	if event.is_action_pressed("remove_fish"):
		removeFish()
			
		
		
