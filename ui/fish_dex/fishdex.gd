extends Control
class_name FishDex

signal closed

const SAVE_PATH = "user://fishdex.json"



@export var hanging_fish_packed : PackedScene

static var _file_read : bool = false

static var fishdex_entries : Dictionary[String,int] = {}
static var FISHES : Dictionary[String,Fish]


@onready var right_tab : Button = %RightTab
@onready var left_tab : Button = %LeftTab

# Fish Descriptions
@onready var current_fish_name : Label = %Fish_Name
@onready var current_fish_texture : TextureRect = %FishArt
@onready var current_fish_rarity : Label = %Rarity
@onready var current_fish_worth : Label = %Worth
@onready var current_fish_description : RichTextLabel = %Description
@onready var current_fish_caught : Label = %Caught

var current_tab = 0
var current_fish_index = 0

func _ready() -> void:
	hide()
	
	##Populate the lookup table
	if FISHES.is_empty():
		for fish : Fish in Fish.leftover_fishes:
			FISHES[fish.fish_name] = fish
		for fish : Fish in Fish.fresh_fishes:
			FISHES[fish.fish_name] = fish
		for fish : Fish in Fish.premium_fishes:
			FISHES[fish.fish_name] = fish
		for fish : Fish in Fish.sushi_fishes:
			FISHES[fish.fish_name] = fish
		for fish : Fish in CharacterSelect.character_bios:
			FISHES[fish.fish_name] = fish
	##Checks if the game has read from file yet
	if not _file_read:
		load_file()
		_file_read = true
	
	populate_stall()
	_update_tabs()
	if $VBoxContainer/CarouselContainer.get_child_count() > 0:
		update_info($VBoxContainer/CarouselContainer.get_child(0).fish)
	else:
		update_info(null)
		%Description.text = "Welcome to the fishdex! Caught fish will be logged here with their name, rarity, value, number caught, and description!"
	
	#if OS.is_debug_build():
		#for fish_name in LIST_OF_FISH:
			#fishdex_entries[fish_name] = 1
			#fishdex_order.append(fish_name)
			#fishdex_order.sort_custom(custom_sort_fish)
	
func load_file() -> void:
	##Done if first time or the file got deleted
	if not FileAccess.file_exists(SAVE_PATH):
		save_file()
	
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	
	##Load json data into the dictionary
	var dict : Dictionary = json.get_data()
	for key in dict.keys():
		print("test")
		if not FISHES.has(key):
			continue
		
		fishdex_entries.set(key,dict.get(key))
	
	

static func save_file() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(fishdex_entries))

func populate_stall() -> void:
	var fish_names : Array[String] = fishdex_entries.keys()
	fish_names.sort_custom(custom_sort_fish)
	
	for name : String in fish_names:
		var new_hanging_fish : HangingFish = hanging_fish_packed.instantiate()
		new_hanging_fish.set_fish(FISHES.get(name))
		$VBoxContainer/CarouselContainer.add_child(new_hanging_fish)


## Sorts fish base on its grade.
func custom_sort_fish(fish_name_a : String, fish_name_b : String):
		var fish_a : Fish = FISHES[fish_name_a]
		var fish_b : Fish = FISHES[fish_name_b]
		#assert(fish_a != null,"null fish")
		#assert(fish_b != null,"null fish")
		##HACK: I have no clue what this function is supposed to do, so this is a weird hack
		
		if fish_a.grade < fish_b.grade:
			return true
		
		if fish_a.grade > fish_b.grade:
			return false
		
		return fish_name_a < fish_name_b

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting FishDex")
	hide()


static func caught_fish(new_fish : Fish) -> void:
	if fishdex_entries.has(new_fish.fish_name):
		fishdex_entries[new_fish.fish_name] += 1
	else:
		fishdex_entries[new_fish.fish_name] = 1
	save_file()


func _on_left_tab_pressed() -> void:
	$VBoxContainer/CarouselContainer.left()
	_update_tabs()

func _on_right_tab_pressed() -> void:
	$VBoxContainer/CarouselContainer.right()
	_update_tabs()
	
func _update_tabs() -> void:
	var current_selected = $VBoxContainer/CarouselContainer.current_selected
	Debug.log("selected ",current_selected)
	if current_selected-1 < 0:
		left_tab.hide()
	else:
		left_tab.show()
	
	if current_selected+1 >= fishdex_entries.size():
		right_tab.hide()
	else:
		right_tab.show()

func _on_fish_selected(node: Node) -> void:
	var hanging_fish : HangingFish = node
	var fish : Fish = hanging_fish.fish
	update_info(fish)

func update_info(fish : Fish) -> void:
	if fish != null:
		current_fish_name.text = fish.fish_name
		current_fish_texture.texture = fish.sprite
		current_fish_rarity.text = fish.grade_string()
		if fish.grade == Fish.Grade.NOT_A_FISH:
			current_fish_worth.add_theme_font_size_override("font_size",13)
			current_fish_worth.text = str("1,000,000,000,000¤")
			var playcount : int = fishdex_entries.get(fish.fish_name)
			current_fish_caught.text = str("Played ",playcount," time", "" if playcount == 1 else "s")
		else:
			current_fish_worth.add_theme_font_size_override("font_size",25)
			current_fish_worth.text = str(fish.get_score(),"¤")
			current_fish_caught.text = str(fishdex_entries.get(fish.fish_name)," Caught")
		current_fish_description.text = fish.description
	else:
		current_fish_name.text = ""
		current_fish_texture.texture = null
		current_fish_rarity.text = ""
		current_fish_worth.text = ""
		current_fish_caught.text = ""
		current_fish_description.text = ""
