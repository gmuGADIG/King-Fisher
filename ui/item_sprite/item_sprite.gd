@tool
class_name ItemSprite
extends Node

var visible_item: String: 
	set(v):
		visible_item = v
		update_visible_item()

@onready var item_root = %ItemRoot

func _ready() -> void:
	update_visible_item()

func update_visible_item():
	if not is_node_ready(): return
	for item in item_root.get_children():
		item.visible = item.name == visible_item

# programmatically generate the exported property list.
#
# all this function does is create an enum in the inspector property list
# that fits what `visible_item` is expecting.
func _get_property_list() -> Array[Dictionary]:
	return [{
		"name": "visible_item",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "- nothing -," + ",".join(item_root.get_children()
				.map(func(node: Node) -> String: return node.name))
	}]
