extends Control
signal closed

var ITEMS = []
var page = 0

@onready var left_arrow = $Background/LeftArrow
@onready var right_arrow = $Background/RightArrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	load_items()

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting Itemdex")
	hide()

func setup_item(index : int) -> void:
	var page_location = index - (page*4) + 1
	var item = ITEMS[index].instantiate()
	get_node("Background/Item"+str(page_location)+"Container/Box/Image").texture = item.sprite
	get_node("Background/Item"+str(page_location)+"Container/Textbox/Description").text = "Description: " + item.description
	get_node("Background/Item"+str(page_location)+"Container/Textbox/Lore").text = "Lore: " + item.lore

func draw_page() -> void:
	for i in range(4):
		var index = page*4 + i
		var page_location = i + 1
		if index < len(ITEMS):
			setup_item(index)
			get_node("Background/Item"+str(page_location)+"Container").show()
		else:
			get_node("Background/Item"+str(page_location)+"Container").hide()
	if page == 0:
		left_arrow.hide()
	else:
		left_arrow.show()

	if (page+1)*4 <= len(ITEMS):
		right_arrow.show()
	else:
		right_arrow.hide()

var BlOCKEDITEMS = [
	"item_base.tscn",
	"swingable_item.tscn",
	"throwable_item.tscn",
]

func loop_through_dir(location : String) -> void:
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn") and file_name not in BlOCKEDITEMS:
				var item_resource = load(location + "/" + file_name)
				ITEMS.append(item_resource)
			file_name = dir.get_next()
		dir.list_dir_end()

func load_items() -> void:
	var location = "res://items"
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				loop_through_dir(location + "/" + file_name)
			elif file_name.ends_with(".tscn") and file_name not in BlOCKEDITEMS:
				var item_resource = load(location + "/" + file_name)
				ITEMS.append(item_resource)
			file_name = dir.get_next()
		ITEMS.sort()
		dir.list_dir_end()

func custom_sort_items(a, b):
	var a_name = a.get("item_name")
	var b_name = b.get("item_name")
	return a_name < b_name


func _on_left_arrow_pressed() -> void:
	page -= 1
	draw_page()

func _on_right_arrow_pressed() -> void:
	page += 1
	draw_page()

var first_draw = true
func _draw() -> void:
	if not first_draw:
		first_draw = false
		return
	draw_page()
