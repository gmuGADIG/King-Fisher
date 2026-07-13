class_name HeldItemUI extends Control

@onready var item_sprite: ItemSprite = %ItemSprite

var item_to_string_table: Dictionary[Script, String] = {
	BananaPeel: "BananaPeel",
	FishingNet: "Butterfly Net",
	GoldenWorm: "Golden Worm",
	Helmet: "Helmet",
	ZiplockBag: "Ziplock Bag",
	RubberMallet: "Rubber Mallet",
	GlueGrenade: "Glue Grenade",
	Brick: "Brick"
}

# func _ready() -> void:
# 	item_sprite.visible_item = "" # clear visible item

func clear_item() -> void:
	item_sprite.visible_item = ""

func hold_item(item: Item) -> void:
	item_sprite.visible_item = item_to_string_table[item.get_script()]
