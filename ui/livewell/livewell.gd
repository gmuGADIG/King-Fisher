extends Control

@export var livewell_entry_packed : PackedScene
var livewell_entries : Array[LivewellEntry]

@onready var grid_container : GridContainer = $Background/GridContainer
@onready var score_label : RichTextLabel = $Background/Score

func _ready() -> void:
	hide()


	
##TODO: Feed in an array of buffs and feed it into the label on the top
func update_buffs() -> void:
	pass

func update_inventory_visuals(fish_inventory : Array[Fish], new_score : int) -> void:
	var fish_counts : Dictionary[Fish,int]
	for fish in fish_inventory:
		if fish_counts.has(fish): 
			fish_counts[fish] += 1 ##Check to see if this works
		else:
			fish_counts.set(fish,1)
	
	if livewell_entries.size() < fish_counts.size():
		var new_entry : LivewellEntry = livewell_entry_packed.instantiate()
		livewell_entries.append(new_entry)
		grid_container.add_child(new_entry)
	elif livewell_entries.size() > fish_counts.size():
		var removed_entry : LivewellEntry = livewell_entries.pop_back()
		removed_entry.queue_free()
		pass
	
	var keys : Array[Fish] = fish_counts.keys()
	keys.sort_custom(Fish.custom_sort_fish)
	
	for i in keys.size():
		livewell_entries[i].set_fish(keys[i],fish_counts[keys[i]])
	
	score_label.text = "[u]"+str(new_score)+" pts[/u]"
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu") and not UIState.more_ui_blocked:
		UIState.ui_state = UIState.State.LIVEWELL
		show()
	elif event.is_action_released("livewell_menu") and UIState.ui_state == UIState.State.LIVEWELL:
		UIState.ui_state = UIState.State.NONE
		hide()
