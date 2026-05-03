class_name LobbySettings
extends Control

enum SpawnRate {
	LOW,
	MEDIUM,
	HIGH
}
var mapPool = ["res://world/catwalk/catwalk.tscn","res://world/heightmap_test/heightmap_test.tscn","res://world/level-coffin/level-coffin.tscn","res://world/level-docks/level-docks.tscn","res://world/catwalk/catwalk.tscn"]
## The maximum time allowed for a round, in seconds.
@export var maximumRoundTime: int = 300

@export_group("Default Settings")

# TODO: replace with names of actual maps
## The default maps selected for a round.
@export_flags("Map1","Map2","Map3","Map4","Map5")
var defaultMapSelect: int

## The default song selection for the round.
@export var defaultMusicSelect: int
## The amount of time for each round by default, in seconds.
@export var defaultRoundTime: int = 60
## The default spawn rate for items.
@export var defaultItemSpawn: SpawnRate = SpawnRate.MEDIUM
## The default spawn rate for fish.
@export var defaultFishSpawn: SpawnRate = SpawnRate.MEDIUM

## The default selection of items spawned.
@export_flags("Rubber Mallet", "Butterfly Net", "Banana Peel", "Brick",
	"Glue Grenade", "Helmet", "Ziplock Bag", "Golden Worm")
var defaultItemSelect: int

## The current length of each round, in seconds.
static var roundTime: int
## The current spawn rate of items (Low, Medium, or High).
static var itemSpawn: SpawnRate
## The current spawn rate of fish (Low, Medium, or High).
static var fishSpawn: SpawnRate
## The currently selected items to spawn in this game.
static var itemSelect: int
## The currently selected maps to use in this game.
static var mapSelect: int
## The ID of the currently selected song.
static var musicSelect: int

@onready var panel: Control = $Background
@onready var timerInput: LineEdit = %MinuteBox
@onready var itemRateSelection: ItemList = %ItemRateSelect
@onready var fishRateSelection: ItemList = %FishRateSelect
@onready var itemSelectList := %ItemSelection.find_children("*", "TextureButton")
@onready var mapSelectList := %MapSelection.find_children("*", "TextureButton")
@onready var musicButton: OptionButton = %SongOptions

func _ready() -> void:
	_on_reset_button_pressed()
	panel.hide()
	panel.draw.connect(update_menu);

## Refreshes the menu with the current settings.
## This is called automatically when the panel becomes visible.
func update_menu() -> void:
	update_timer()
	itemRateSelection.select(itemSpawn)
	fishRateSelection.select(fishSpawn)
	set_buttons_from_bitmask(itemSelectList, itemSelect)
	set_buttons_from_bitmask(mapSelectList, mapSelect)
	musicButton.select(musicButton.get_item_index(musicSelect))

## Save current lobby settings to memory.
func _on_save_button_pressed() -> void:
	# Round timer
	var timerText := timerInput.text.split(":")
	match timerText.size():
		2:
			roundTime = int(timerText[0]) * 60 + int(timerText[1])
		1:
			roundTime = int(timerText[0]) * 60
		_:
			roundTime = defaultRoundTime
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
	musicSelect = musicButton.get_item_id(musicButton.get_selected())
	print(roundTime)
	print(itemSpawn)
	print(fishSpawn)
	print(itemSelect)
	
	print("Maps" +str(String.num_int64(mapSelect,2)))
	print(musicSelect)
	Multiplayer.set_map(String.num_int64(mapSelect,2),mapPool)

## Reset settings to default.
func _on_reset_button_pressed() -> void:
	roundTime = defaultRoundTime
	itemSpawn = defaultItemSpawn
	fishSpawn = defaultFishSpawn
	itemSelect = defaultItemSelect
	mapSelect = defaultMapSelect
	musicSelect = defaultMusicSelect
	update_menu()

## Stores the set of selected buttons as a bitmask.
func get_bitmask_from_buttons(buttons: Array[Node]) -> int:
	var mask: int = 0
	var inc: int = 1
	for button in buttons:
		if button is BaseButton:
			if button.button_pressed:
				mask += inc
			inc <<= 1
	return mask

## Uses a bitmask to set the state of a list of buttons.
func set_buttons_from_bitmask(buttons: Array[Node], bitmask: int) -> void:
	for button in buttons:
		if button is BaseButton:
			button.button_pressed = bool(bitmask & 1)
			bitmask >>= 1

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("lobby_settings") && multiplayer.is_server()):
		print("huh?")
		print("Menu pressed")
		print("Authority checked")
		visible = not visible
		panel.visible = visible
		# panel.visible = !panel.visible

		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_timer_more_button_pressed() -> void:
	if (roundTime < maximumRoundTime):
		roundTime = clampi(roundTime + 30, 0, maximumRoundTime)
		%LessButton.disabled = false
	if (roundTime == maximumRoundTime): %MoreButton.disabled = true
	update_timer()

func _on_timer_less_button_pressed() -> void:
	if (roundTime > 0):
		roundTime = clampi(roundTime - 30, 0, maximumRoundTime)
		%MoreButton.disabled = false
	if (roundTime == 0): %LessButton.disabled = true
	update_timer()

func _on_minute_box_editing_toggled(toggled_on: bool) -> void:
	if toggled_on: return
	if timerInput.text.contains(":"):
		var timerText = timerInput.text.split(":")
		roundTime = int(timerText[0]) * 60 + int(timerText[1])
	else:
		roundTime = int(timerInput.text)
	roundTime = clampi(roundTime, 0, maximumRoundTime)
	update_timer()

func update_timer() -> void:
	@warning_ignore("integer_division")
	timerInput.text = "%d:%02d" % [roundTime / 60, roundTime % 60]

func _on_exit_button_pressed() -> void:
	panel.visible = false
