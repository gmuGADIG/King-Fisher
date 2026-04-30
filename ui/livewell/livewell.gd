class_name Livewell
extends Control

@export var fish_info_packed : PackedScene

var fish_inventory: Dictionary[String, livewell_fish_info] = {}
var fish_sorted_inventory : Array[String] = []
@onready var livewellPanel : Panel = $Background
# Buffs
var active_buffs_list : Array[String] = []
@onready var active_buffs : Label = $Background/ActiveBuffs
@onready var active_buffs_underline : ColorRect = $Background/ActiveBuffsUnderline
# Score
@onready var score : Label = $Background/Score
@onready var score_underline : ColorRect = $Background/ScoreUnderline
@onready var top_fish_container : HBoxContainer = $Background/TopFishPanel/TopFishContainer
@onready var bottom_fish_container : HBoxContainer = $Background/BottomFishPanel/BottomFishContainer
var top_fish : Dictionary[String, LivewellFish] = {}
var bottom_fish : Dictionary[String, LivewellFish] = {}
var current_score : int = 0;

func _ready() -> void:
	var item_size = 175
	var offset_distance = item_size + (item_size * 0.15)

	top_fish_container.add_theme_constant_override("separation", offset_distance)
	active_buffs.text = ""
	active_buffs_underline.size.x = 0
	hide()

func add_buff(buff : String) -> void:
	if buff in active_buffs_list: return
	active_buffs_list.append(buff)
	active_buffs.text = " | ".join(active_buffs_list)
	active_buffs_underline.size.x = get_text_pixel_width(active_buffs.text, active_buffs) / 1.5
	active_buffs_underline.position.x = active_buffs.position.x + (active_buffs.size.x / 1.75) - (active_buffs_underline.size.x / 2)

func remove_buff(buff : String) -> void:
	if not buff in active_buffs_list: return
	active_buffs_list.erase(buff)
	active_buffs.text = ", ".join(active_buffs_list)
	active_buffs_underline.size.x = get_text_pixel_width(active_buffs.text, active_buffs) * 1.25
	active_buffs_underline.position.x = active_buffs.position.x + (active_buffs.size.x / 2) - (active_buffs_underline.size.x / 2)

func addFish(new_fish : Fish, amount : int = 1) -> void:
	if fish_inventory.has(new_fish.fish_name):
		fish_inventory.get(new_fish.fish_name).fish_count += amount
	else:
		var fish_info = livewell_fish_info.new()
		fish_info.fish = new_fish
		fish_info.fish_count = amount
		fish_inventory.set(new_fish.fish_name, fish_info)
		fish_sorted_inventory.append(new_fish.fish_name)
		fish_sorted_inventory.sort_custom(func(a, b):
			var fish_a = fish_inventory.get(a).fish
			var fish_b = fish_inventory.get(b).fish
			return fish_a.grade > fish_b.grade
		)
		top_fish.clear()
		bottom_fish.clear()
		for child in top_fish_container.get_children():
			child.queue_free()
		for child in bottom_fish_container.get_children():
			child.queue_free()
	
	changeScore(new_fish.get_score())
	updateVisuals()
	Debug.log("added fish: ", new_fish.fish_name)

## Removes a fish from the livewell
## first argument specifies the kind of fish, if null it picks a random one
## second argument specifies the amount
##
## returns the fish type if successful, null otherwise
##
## WARN: this function can only batch remove fish of the same type
## so if amount == 2 and fish == null, the function will fail
## if the player has 1 fish, or two fish of different type.
func removeFish(fish : Fish = null, amount : int = 1) -> Fish:
	if fish_inventory.is_empty(): return null

	# pick a random fish if no fish type was specified
	# BUG this isn't multiplayer safe, picks a different random per client i think
	# can be avoided by just making the calling client randomly pick a fish,
	# then RPC calling this function with it as an argument
	if fish == null:
		var fish_name = fish_inventory.keys().pick_random()
		fish = fish_inventory[fish_name].fish

	if not fish_inventory.has(fish.fish_name): return null
	elif fish_inventory.get(fish.fish_name).fish_count <= amount:
		fish_inventory.get(fish.fish_name).fish_count = 0
	else:
		fish_inventory.get(fish.fish_name).fish_count -= amount

	changeScore(-fish.get_score())
	updateVisuals()
	Debug.log("removed fish: ", fish.fish_name)
	return fish

## These functions are RPC safe so you can add a fish over multiplayer.

@rpc ("authority", "call_local", "reliable")
func addFishByName(fish_name: String):
	addFish(fish_inventory[fish_name].fish)
@rpc ("authority", "call_local", "reliable")
func removeFishByName(fish_name: String):
	removeFish(fish_inventory[fish_name].fish)

func changeScore(change : int):
	current_score += change
	# Failsafe to prevent negative score
	if current_score < 0:
		current_score = 0
	score.text = str(current_score) + " pts"
	score_underline.size.x = get_text_pixel_width(score.text, score)
	score_underline.position.x = score.position.x + (score.size.x / 2) - (score_underline.size.x / 1.5)

func updateVisuals() -> void:
	#for fish_name in fish_sorted_inventory:
		#var fish = fish_inventory.get(fish_name)
		#var fish_location = null
#
		#if top_fish.has(fish_name): fish_location = top_fish
		#elif bottom_fish.has(fish_name): fish_location = bottom_fish
#
		#if fish_location != top_fish and fish_location != bottom_fish:
			#var fish_info : LivewellFish = fish_info_packed.instantiate()
			#fish_info.name = fish_name
			#fish_info.set_fish(fish.fish.sprite.get_path(), fish)
			#if top_fish_container.get_child_count() < 5:
				#top_fish_container.add_child(fish_info)
				#top_fish.set(fish_name, fish_info)
			#else:
				#bottom_fish_container.add_child(fish_info)
				#bottom_fish.set(fish_name, fish_info)
		#else:
			#var fish_info : LivewellFish = fish_location.get(fish_name)
			#if fish.fish_count == 0:
				#fish_info.queue_free()
				#top_fish.erase(fish_name)
				#fish_inventory.erase(fish_name)
				#fish_sorted_inventory.erase(fish_name)
			#elif fish.fish_count > 1:
				#fish_info.count.text = str(fish.fish_count) + "x"
				#fish_info.count.visible = true
			#else:
				#fish_info.count.visible = false
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		visible = !visible
## This code was moved to the player.
	#if event.is_action_pressed("add_fish"):
		#var newFish : Fish = load("res://fish/sushi/fish_seven.tres")
		#addFish(newFish)
	#if event.is_action_pressed("remove_fish"):
		#var newFish : Fish = load("res://fish/sushi/fish_seven.tres")
		#removeFish(newFish)

func get_text_pixel_width(text: String, label_node: Label) -> float:
	var font = label_node.get_theme_font("font")
	var font_size = label_node.get_theme_font_size("font_size")

	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	return text_size.x
