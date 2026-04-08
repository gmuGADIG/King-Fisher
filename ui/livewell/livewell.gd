extends Control

@export var fish_info_packed : PackedScene

var fish_inventory: Dictionary[String, livewell_fish_info] = {}
@onready var livewellPanel : Panel = $Background
@onready var score : Label = $Background/Score
@onready var top_fish_container : HBoxContainer = $Background/TopFishPanel/TopFishContainer
@onready var bottom_fish_container : HBoxContainer = $Background/BottomFishPanel/BottomFishContainer
var top_fish : Dictionary[String, LivewellFish] = {}
var bottom_fish : Dictionary[String, LivewellFish] = {}
var current_score : int = 0;

func _ready() -> void:
	var item_size = 175
	var offset_distance = item_size + (item_size * 0.15)

	top_fish_container.add_theme_constant_override("separation", offset_distance)
	hide()

func addFish(new_fish : Fish, amount : int = 1) -> void:
	if fish_inventory.has(new_fish.fish_name):
		fish_inventory.get(new_fish.fish_name).fish_count += amount
	else:
		var fish_info = livewell_fish_info.new()
		fish_info.fish = new_fish
		fish_info.fish_count = amount
		fish_inventory.set(new_fish.fish_name, fish_info)
	
	changeScore(new_fish.get_score())
	updateVisual()

func removeFish(fish : Fish, amount : int = 1) -> void:
	print(fish_inventory.size())
	if(!fish_inventory.has(fish.fish_name) or fish_inventory.size() == 0): return
	elif fish_inventory.get(fish.fish_name).fish_count <= amount:
		fish_inventory.get(fish.fish_name).fish_count = 0
	else:
		fish_inventory.get(fish.fish_name).fish_count -= amount
	changeScore(-fish.get_score())
	updateVisual()

func changeScore(change : int):
	current_score += change
	# Failsafe to prevent negative score
	if current_score < 0:
		current_score = 0
	score.text = str(current_score) + " pts"

func updateVisual() -> void:
	for fish in fish_inventory.values():
		var fish_name = fish.fish_name()
		if top_fish.has(fish_name):
			var fish_info : LivewellFish = top_fish.get(fish_name)
			if fish.fish_count == 0:
				fish_info.queue_free()
				top_fish.erase(fish_name)
				fish_inventory.erase(fish_name)
			elif fish.fish_count > 1:
				fish_info.count.text = str(fish.fish_count) + "x"
				fish_info.count.visible = true
		elif bottom_fish.has(fish_name):
			var fish_info : LivewellFish = bottom_fish.get(fish_name)
			if fish.fish_count == 0:
				fish_info.queue_free()
				bottom_fish.erase(fish_name)
				fish_inventory.erase(fish_name)
			else:
				fish_info.count.text = str(fish.fish_count) + "x"
				fish_info.count.visible = true
		else:
			var fish_info : LivewellFish = fish_info_packed.instantiate()
			fish_info.name = fish_name
			fish_info.set_fish(fish.fish.sprite.get_path(), fish)
			if top_fish_container.get_child_count() < 5:
				top_fish_container.add_child(fish_info)
				top_fish.set(fish_name, fish_info)
			elif bottom_fish_container.get_child_count() < 5:
				bottom_fish_container.add_child(fish_info)
				bottom_fish.set(fish_name, fish_info)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		visible = !visible
	if event.is_action_pressed("add_fish"):
		var newFish : Fish = load("res://fish/fresh/test_fish.tres")
		var newFish1 : Fish = load("res://fish/sushi/fish_seven.tres")
		addFish(newFish)
		# addFish(newFish1)
	if event.is_action_pressed("remove_fish"):
		var newFish : Fish = load("res://fish/fresh/test_fish.tres")
		var newFish1 : Fish = load("res://fish/sushi/fish_seven.tres")
		removeFish(newFish)
		# removeFish(newFish1)
