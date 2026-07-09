class_name HeldItemUI extends Control

@onready var item_sprite: ItemSprite = %ItemSprite

# func _ready() -> void:
# 	item_sprite.visible_item = "" # clear visible item

func clear_item() -> void:
	item_sprite.visible_item = ""

func hold_item(item_name: String) -> void:
	item_sprite.visible_item = item_name
