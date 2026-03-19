extends Node

var livewellInventory = []
@export var currentFish : String
@onready var livewellPanel : Panel = $Panel
@onready var fish : Label = $Panel/VBoxContainer/Fish
@onready var score : Label = $Panel/VBoxContainer/Score
var intScore : int = 0;

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
	livewellInventory.remove_at(0)
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
		currentFish = currentFish + printFish.fish_name + " (" + str(gradeType) + ")\n"  
	fish.text = currentFish
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		livewellPanel.visible = !livewellPanel.visible
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/sushi/test_fish.tres")
		addFish(newFish)
	if event.is_action_pressed("remove_fish"):
		removeFish()
			
		
		
