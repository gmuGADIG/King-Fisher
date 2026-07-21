class_name HeldItemUI extends Control

@onready var item_sprite: ItemSprite = %ItemSprite

var item_to_type_table: Dictionary[Script, Item.Type] = {
	BananaPeel: Item.Type.BANANA_PEEL,
	FishingNet: Item.Type.BUTTERFLY_NET,
	GoldenWorm: Item.Type.GOLDEN_WORM,
	Helmet: Item.Type.HELMET,
	ZiplockBag: Item.Type.ZIPLOCK_BAG,
	RubberMallet: Item.Type.RUBBER_MALLET,
	GlueGrenade: Item.Type.GLUE_GRENADE,
	Brick: Item.Type.BRICK
}

func _ready() -> void:
	UIState.state_updated.connect(_state_updated)
	clear_item()

func clear_item() -> void:
	item_sprite.visible_item = Item.Type.NONE

func hold_item(item: Item) -> void:
	var item_type : Item.Type = item_to_type_table[item.get_script()]
	if BananaPeel.armadillo_mode and item_type == Item.Type.BANANA_PEEL:
		item_type = Item.Type.ARMADILLO
	item_sprite.visible_item = item_type

func _state_updated(new_state : UIState.State) -> void:
	match new_state:
		UIState.State.CHARACTER_SELECT, UIState.State.TUTORIAL,UIState.State.LOBBY_SETTINGS, UIState.State.LIVEWELL, UIState.State.FISHING_MINIGAME:
			hide()
		_:
			show()
