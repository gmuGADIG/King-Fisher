extends Control

var fish_inventory: Dictionary[String, livewell_fish_info] = {}
var current_fish : Fish
@onready var livewellPanel : Panel = $Panel
@onready var score : Label = $Panel/Score
@onready var top_fish_container : VBoxContainer = $Panel/VBoxContainer/TopFishContainer
var current_score : int = 0;

func _ready() -> void:
	hide()

func addFish(new_fish : Fish, amount : int = 1) -> void:
	current_fish = new_fish
	if fish_inventory.has(new_fish.fish_name):
		fish_inventory[new_fish.fish_name].fish_count += amount
	else:
		fish_inventory[new_fish.fish_name] = livewell_fish_info.new()
		fish_inventory[new_fish.fish_name].fish = new_fish
		fish_inventory[new_fish.fish_name].fish_count = amount
	
	changeScore(new_fish.get_score())
	updateVisual()

func changeScore(change : int):
	current_score += change
	# Failsafe to prevent negative score
	if current_score < 0:
		current_score = 0
	score.text = str(current_score) + " pts"

func removeFish(fish : Fish, amount : int = 0) -> void:
	if(fish_inventory.size() == 0 or !fish_inventory.has(fish.fish_name)):
		return
	if fish_inventory[fish.fish_name].fish_count >= amount:
		fish_inventory[fish.fish_name].fish_count = 0
	else:
		fish_inventory[fish.fish_name].fish_count -= amount
	changeScore(-fish.get_score())
	updateVisual()

func updateVisual() -> void:
	for fish in fish_inventory:
		var grade = Fish.Grade.UNSET
		if(fish.grade == printFish.Grade.SUSHI):
			gradeType += 1
			sprites.texture = printFish.sprite
		current_fish = current_fish + printFish.fish_name + " (" + str(gradeType) + ")\n"  
	fish.text = current_fish
	if(!fish_inventory.size()):
		fishCount.text = ""
	else:
		fishCount.text = "x" + str(fish_inventory.size())
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		visible = !visible
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/sushi/test_fish.tres")
		addFish(newFish)
	if event.is_action_pressed("remove_fish"):
		removeFish()
			
		
		
