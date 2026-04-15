extends Control

signal closed

const SAVE_PATH = "user://fishdex.json"

var loaded : bool = false
var fishdex_entries : Dictionary = {}
var fishdex_order : Array = []
@onready var LIST_OF_FISH : Dictionary = {}
var first_draw : bool = true
@onready var current_fish : Control = $Current_Fish
@onready var selectable_fish_1 : Control = $Selectable_Fish_1
@onready var selectable_fish_2 : Control = $Selectable_Fish_2

# Fish Descriptions
@onready var current_fish_name : Label = $Stall/Fish_Info/Name_Box/Fish_Name
@onready var current_fish_rarity : Label = $Stall/Fish_Info/Fish_Rarity_Worth/Rarity_Box/Rarity
@onready var current_fish_worth : Label = $Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box/Worth
@onready var current_fish_description : Label = $Stall/Description_Box/Description
@onready var current_fish_caught : Label = $Stall/Fish_Info/Caught_Box/Caught

func _ready() -> void:
	hide()

	load_file()
	loaded = true

func custom_sort_fish(a, b):
		var fish_a = LIST_OF_FISH.get(a).fish
		var fish_b = LIST_OF_FISH.get(b).fish
		return fish_a.grade > fish_b.grade

func load_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			fishdex_entries = json.get_data()
			fishdex_order.sort_custom(custom_sort_fish)
		load_all_fish_resources()
	else:
		save_file(true)

func load_all_fish_resources():
	var dir = DirAccess.open("res://fish/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var fish = load("res://fish/" + file_name)
				LIST_OF_FISH.append(fish)
			file_name = dir.get_next()

func caught_fish(new_fish : Fish) -> void:
	if fishdex_entries.has(new_fish.fish_name):
		fishdex_entries[new_fish.fish_name] += 1
		fishdex_order.append(new_fish.fish_name)
		fishdex_order.sort_custom(custom_sort_fish)
	else:
		fishdex_entries[new_fish.fish_name] = 1
		fishdex_order.append(new_fish.fish_name)
		fishdex_order.sort_custom(custom_sort_fish)
	save_file()

func save_file(first_time : bool = false) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(fishdex_entries))
	if first_time:
		load_file()

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting FishDex")
	hide()

func _on_draw() -> void:
	print(len(fishdex_order))
	if first_draw:
		first_draw = false
		
		if len(fishdex_order) > 0:
			current_fish.fish = LIST_OF_FISH.get(fishdex_order[0])
			current_fish_name.text = current_fish.fish.name
			current_fish_rarity.text = current_fish.fish.rarity
			current_fish_worth.text = str(current_fish.fish.worth)
			current_fish_description.text = current_fish.fish.description
			current_fish_caught.text = "Caught: " % fishdex_entries.get(current_fish.fish.name, 0)

			if len(fishdex_order) > 1:
				selectable_fish_1.fish = LIST_OF_FISH.get(fishdex_order[1])
			if len(fishdex_order) > 2:
				selectable_fish_2.fish = LIST_OF_FISH.get(fishdex_order[2])
		else:
			current_fish_name.text = "No Fish Caught"
			current_fish_rarity.hide()
			$Stall/Fish_Info/Fish_Rarity_Worth/Rarity_Box.hide()
			current_fish_worth.hide()
			$Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box.hide()
			current_fish_description.hide()
			$Stall/Description_Box.hide()
			current_fish_caught.hide()
			$Stall/Fish_Info/Caught_Box.hide()
			var newFish : Fish = load("res://fish/sushi/test_fish.tres")
			caught_fish(newFish)
	else:
		if len(fishdex_order) > 0:
			current_fish.fish = LIST_OF_FISH.get(fishdex_order[0])
			current_fish_name.text = current_fish.fish.name
			current_fish_rarity.text = current_fish.fish.rarity
			current_fish_worth.text = str(current_fish.fish.worth)
			current_fish_description.text = current_fish.fish.description
			current_fish_caught.text = "Caught: " % fishdex_entries.get(current_fish.fish.name, 0)

			if len(fishdex_order) > 1:
				selectable_fish_1.fish = LIST_OF_FISH.get(fishdex_order[1])
			if len(fishdex_order) > 2:
				selectable_fish_2.fish = LIST_OF_FISH.get(fishdex_order[2])
