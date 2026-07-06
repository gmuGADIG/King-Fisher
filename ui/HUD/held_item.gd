class_name HeldItemUI extends Control

@onready var held_item_root = %ItemRoot


@onready var banana_peel = %BananaPeel
@onready var fishing_net = %"Butterfly Net"
@onready var golden_worm = %"Golden Worm"
@onready var helmet = %Helmet
@onready var ziplock_bag = %"Ziplock Bag"
@onready var rubber_mallet = %"Rubber Mallet"
@onready var glue_grenade = %"Glue Grenade"
@onready var brick = %Brick

func _ready() -> void:
	clear_item()
	print("Hide")
	
	if get_tree().current_scene.name == "Lobby":
		modulate = Color(0,0,0,0)
	else:
		UIState.state_updated.connect(_ui_state_updated)
	
func _ui_state_updated(state : UIState.State) -> void:
	if state == UIState.State.LIVEWELL:
		hide()
	elif state == UIState.State.NONE:
		show()

func hold_item(item: Item) -> void:
	clear_item()
	print("Showing item")
	if item is BananaPeel:
		banana_peel.show()
	elif item is FishingNet:
		fishing_net.show()
	elif item is GoldenWorm:
		golden_worm.show()
	elif item is Helmet:
		helmet.show()
	elif item is ZiplockBag:
		ziplock_bag.show()
	elif item is RubberMallet:
		rubber_mallet.show()
	elif item is GlueGrenade:
		glue_grenade.show()
	elif item is Brick:
		brick.show()
	else:
		assert(false,"Invalid item")

func clear_item() -> void:
	for item in held_item_root.get_children():
		item.visible = false
