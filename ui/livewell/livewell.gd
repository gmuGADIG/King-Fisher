extends Control

@export var fish_info_packed : PackedScene

var fish_inventory: Dictionary[String, LivewellFishInfo] = {}
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
		fish_inventory.get(new_fish.fish_name).fish_count += amount
	else:
		var fish_info = LivewellFishInfo.new()
		fish_info.fish = new_fish
		fish_info.fish_count = amount
		fish_info.grade = new_fish.grade
		fish_inventory.set(new_fish.fish_name, fish_info)
	
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
	for fish in fish_inventory.values():
		var fish_info : LivewellFishInfo = fish_info_packed.instantiate()
		fish_info.set_fish(fish.fish_file_name, fish.fish_type)
		
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		visible = !visible
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/sushi/test_fish.tres")
		var newFish1 : Fish = load("res://fish/sushi/fish_seven.tres")
		addFish(newFish)
		addFish(newFish1)
	if event.is_action_pressed("remove_fish"):
		var newFish : Fish = load("res://fish/sushi/test_fish.tres")
		removeFish(newFish)
