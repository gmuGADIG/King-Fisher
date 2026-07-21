extends Control
signal closed

@export var items : Array[PackedScene]
var page = 0

@onready var left_arrow = $Background/LeftArrow
@onready var right_arrow = $Background/RightArrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	items.sort_custom(custom_sort_items)
	print(items)

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting Itemdex")
	hide()

func setup_item(index : int) -> void:
	var page_location = index - (page*2) + 1
	var item = items[index].instantiate()
	
	get_node("Background/Item"+str(page_location)+"Container/Box/Image").texture = item.sprite
	get_node("Background/Item"+str(page_location)+"Container/Textbox/Description").text = "Description: " + item.description
	get_node("Background/Item"+str(page_location)+"Container/Textbox/Lore").text = "Lore: " + item.lore
	item.queue_free()

func draw_page() -> void:
	$Background/Item1Container/HBoxContainer/Description.get_v_scroll_bar().value = 0
	$Background/Item1Container/Lore.get_v_scroll_bar().value = 0
	$Background/Item2Container/HBoxContainer/Description.get_v_scroll_bar().value = 0
	$Background/Item2Container/Lore.get_v_scroll_bar().value = 0
	var item_1 : Item = items[page*2].instantiate()
	var item_2 : Item = items[page*2+1].instantiate()
	
	$Background/Item1Container/HBoxContainer/Box/Image.texture = item_1.sprite
	$Background/Item1Container/HBoxContainer/Description.text = item_1.description
	$Background/Item1Container/Lore.text = item_1.lore
	
	$Background/Item2Container/HBoxContainer/Box/Image.texture = item_2.sprite
	$Background/Item2Container/HBoxContainer/Description.text = item_2.description
	$Background/Item2Container/Lore.text = item_2.lore
	
	if page == 0:
		left_arrow.hide()
	else:
		left_arrow.show()

	if (page+1)*2 < len(items):
		right_arrow.show()
	else:
		right_arrow.hide()

var BlOCKEDITEMS = [
	"item_base.tscn",
	"swingable_item.tscn",
	"throwable_item.tscn",
]



func custom_sort_items(a : PackedScene, b : PackedScene):
	var item_a : Item = a.instantiate()
	var item_b : Item = b.instantiate()
	var result : bool = item_a.item_name < item_b.item_name
	item_a.queue_free()
	item_b.queue_free() 


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
