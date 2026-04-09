class_name LobbySettings
extends Control

enum SpawnRate {
	LOW,
	MEDIUM,
	HIGH
}

@export_group("Default Settings")

# TODO: replace with names of actual maps
## The default maps selected for a round.
@export_flags("Map1","Map2","Map3","Map4","Map5")
var defaultMapSelect: int

## The default song selection for the round.
@export var defaultMusicSelect: String
## The amount of time for each round by default, in seconds.
@export var defaultRoundTimer: int = 60
## The default spawn rate for items.
@export var defaultItemSpawn: SpawnRate = SpawnRate.MEDIUM
## The default spawn rate for fish.
@export var defaultFishSpawn: SpawnRate = SpawnRate.MEDIUM

## The default selection of items spawned.
@export_flags("Rubber Mallet", "Butterfly Net", "Banana Peel", "Brick",
	"Glue Grenade", "Helmet", "Ziplock Bag", "Golden Worm")
var defaultItemSelect: int

static var roundTimer: int
static var itemSpawn: SpawnRate
static var fishSpawn: SpawnRate
static var itemSelect: int
static var mapSelect: int
static var musicSelect: String

@onready var panel: Control = $Background
@onready var timerInput: LineEdit = %MinuteBox
@onready var itemRateSelection: ItemList = %ItemRateSelect
@onready var fishRateSelection: ItemList = %FishRateSelect
@onready var itemSelectList := %ItemSelection.find_children("*", "TextureButton")
@onready var mapSelectList := %MapSelection.find_children("*", "TextureButton")
@onready var musicButton: OptionButton = %SongOptions

func _ready() -> void:
	panel.hide()
	panel.draw.connect(update_menu);

func update_menu() -> void:
	pass

func _on_save_button_pressed() -> void:
	# Round timer
	var timerText := timerInput.text.split(":")
	match timerText.size():
		2:
			roundTimer = int(timerText[0]) * 60 + int(timerText[1])
		1:
			roundTimer = int(timerText[0]) * 60
		_:
			roundTimer = defaultRoundTimer
	# Spawn rates
	if itemRateSelection.is_anything_selected():
		itemSpawn = itemRateSelection.get_selected_items()[0] as SpawnRate
	else: itemSpawn = defaultItemSpawn
	if fishRateSelection.is_anything_selected():
		fishSpawn = fishRateSelection.get_selected_items()[0] as SpawnRate
	else: fishSpawn = defaultFishSpawn
	# Selections
	itemSelect = get_bitmask_from_buttons(itemSelectList)
	mapSelect = get_bitmask_from_buttons(mapSelectList)
	musicSelect = musicButton.get_item_text(musicButton.get_selected())
	print(roundTimer)
	print(itemSpawn)
	print(fishSpawn)
	print(itemSelect)
	print(mapSelect)
	print(musicSelect)
	# File write
	var host_save = FileAccess.open("user://host_settings.cfg", FileAccess.WRITE)
	host_save.store_string(JSON.stringify({
		"roundTimer": roundTimer,
		"itemSpawn": itemSpawn,
		"fishSpawn": fishSpawn,
		"itemSelect": itemSelect,
		"mapSelect": mapSelect,
		"musicSelect": musicSelect
	}))

func get_bitmask_from_buttons(buttons: Array[Node]) -> int:
	var mask: int = 0
	var inc := 0b1
	for button in buttons:
		if button is BaseButton:
			if button.button_pressed:
				mask += inc
			inc <<= 1
	return mask

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("Menu") && multiplayer.is_server()):
		print("Menu pressed")
		print("Authority checked")
		panel.visible = !panel.visible
