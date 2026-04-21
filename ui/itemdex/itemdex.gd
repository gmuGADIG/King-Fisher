extends Control
signal closed

var ITEMS = []
var page = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	load_items()

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting Itemdex")
	hide()

func setup_item(index : int) -> void:
	var page_location = index - (page*4)
	var item = ITEMS[index]
	get_node("Item"+str(page_location)+"Container/Box/Image").texture = item.sprite
	get_node("Item"+str(page_location)+"Container/Box/Description").text = item.description
	get_node("Item"+str(page_location)+"Container/Box/Lore").text = item.lore

func draw_page() -> void:
	for i in range(4):
		var index = page*4 + i
		if index < len(ITEMS):
			setup_item(index)
			get_node("Item"+str(i)+"Container").show()
		else:
			get_node("Item"+str(i)+"Container").hide()

func load_items() -> void:
	var location = "res://items"
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var item_resource = load(location + "/" + file_name)
				ITEMS.append(item_resource)
			file_name = dir.get_next()
		# ITEMS.sort_custom(custom_sort_items)
		ITEMS.sort()
		dir.list_dir_end()

func custom_sort_items(a, b):
		var a_name = a.get("item_name")
		var b_name = b.get("item_name")
		return a_name < b_name
