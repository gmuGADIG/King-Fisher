extends Control
class_name fishdex

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

var current_tab = 0
var current_fish_index = 0

func _ready() -> void:
	hide()

	load_file()
	loaded = true

func custom_sort_fish(a, b):
		var fish_a = LIST_OF_FISH.get(a)
		var fish_b = LIST_OF_FISH.get(b)
		return fish_a.grade > fish_b.grade

func load_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			fishdex_entries = json.get_data()
			for fish_name in fishdex_entries:
				fishdex_order.append(fish_name)
		load_all_fish_resources()
		fishdex_order.sort_custom(custom_sort_fish)
	else:
		save_file(true)

func loop_through_dir(location : String) -> void:
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var fish_resource = load(location + "/" + file_name)
				LIST_OF_FISH[fish_resource.fish_name] = fish_resource
			file_name = dir.get_next()
		dir.list_dir_end()

func load_all_fish_resources():
	loop_through_dir("res://fish/sushi")
	loop_through_dir("res://fish/premium")
	loop_through_dir("res://fish/fresh")
	loop_through_dir("res://fish/leftover")

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
	current_tab = 0
	current_fish_index = 0
	if len(fishdex_order) > 0:
		setup_current_fish()
		setup_current_tab()
	else:
		current_fish_name.text = "No Fish Caught"
		toggle_fishinfo_visibility(false)
		var newFish : Fish = load("res://fish/sushi/fish_seven.tres")
		var newFish2 : Fish = load("res://fish/sushi/sasha_splash.tres")
		var newFish3 : Fish = load("res://fish/sushi/test_fish.tres")
		var newFish4 : Fish = load("res://fish/sushi/yuri_fish.tres")
		caught_fish(newFish)
		caught_fish(newFish2)
		caught_fish(newFish3)
		caught_fish(newFish4)
		$Right_Tab.hide()
		$Left_Tab.hide()

func setup_current_tab() -> void:
	var current_index = current_tab * 2
	if current_fish_index <= current_index:
		current_index += 1
	if current_index >= len(fishdex_order):
		selectable_fish_1.hide()
		return

	selectable_fish_1.fish = LIST_OF_FISH.get(fishdex_order[current_index])
	selectable_fish_1.get_node("Fish_Image").texture = selectable_fish_1.fish.sprite
	selectable_fish_1.show()

	current_index += 1
	if current_fish_index == current_index:
		current_index += 1

	if current_index >= len(fishdex_order):
		selectable_fish_2.hide()
	else:
		selectable_fish_2.fish = LIST_OF_FISH.get(fishdex_order[current_index])
		selectable_fish_2.get_node("Fish_Image").texture = selectable_fish_2.fish.sprite
		selectable_fish_2.show()

	if (current_tab * 2 + 2) < len(fishdex_entries):
		$Right_Tab.show()
	else:
		$Right_Tab.hide()
	if current_tab > 0:
		$Left_Tab.show()
	else:
		$Left_Tab.hide()

# 1 for left 2 for right
func change_tab(left : bool = false, right : bool = false) -> void:
	if left:
		if current_tab > 0:
			Debug.log_err("Fishdex Attempted to change to illegal tab: " + str(current_tab - 1))
		current_tab -= 1
	elif right:
		if len(fishdex_entries) % 2 == 1 or len(fishdex_entries) % 2 == 0:
			if current_tab + 1 > len(fishdex_order)/2 + 1 or current_tab + 1 > len(fishdex_order)/2:
				Debug.log_err("Fishdex Attempted to change to illegal tab: " + str(current_tab + 1))
				return
		current_tab += 1
	setup_current_tab()


func setup_current_fish() -> void:
	current_fish.fish = LIST_OF_FISH.get(fishdex_order[0])
	current_fish_name.text = current_fish.fish.fish_name
	current_fish_rarity.text = str(current_fish.fish.grade)
	current_fish_worth.text = str(current_fish.fish.get_score())
	current_fish_description.text = current_fish.fish.description
	current_fish_caught.text = "Caught: " + str(fishdex_entries.get(current_fish.fish.fish_name, 0))
	toggle_fishinfo_visibility(true)
	current_fish.show()
	current_fish.get_node("Fish_Image").texture = current_fish.fish.sprite

func toggle_fishinfo_visibility(toggle : bool) -> void:
	if toggle:
		$Stall/Fish_Info/Fish_Rarity_Worth/Rarity_Box.show()
		current_fish_rarity.show()
		$Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box.show()
		current_fish_worth.show()
		$Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box/Worth.show()
		current_fish_description.show()
		$Stall/Description_Box.show()
		current_fish_caught.show()
		$Stall/Fish_Info/Caught_Box.show()
	else:
		$Stall/Fish_Info/Fish_Rarity_Worth/Rarity_Box.hide()
		current_fish_rarity.hide()
		$Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box.hide()
		current_fish_worth.hide()
		$Stall/Fish_Info/Fish_Rarity_Worth/Worth_Box/Worth.hide()
		current_fish_description.hide()
		$Stall/Description_Box.hide()
		current_fish_caught.hide()
		$Stall/Fish_Info/Caught_Box.hide()


func _on_left_tab_pressed() -> void:
	change_tab(true)

func _on_right_tab_pressed() -> void:
	change_tab(false, true)
