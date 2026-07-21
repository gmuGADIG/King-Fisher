class_name LobbySettings
extends Control


enum SpawnRate {
	LOW,
	MEDIUM,
	HIGH
}

const RANDOM_SONG : int = 0
#var igabla : int = 0
static var song_pool : Dictionary[String,Song] = {
	"Ben Song" : load("res://sound/music/song_files/main_level_ben.tres"),
	"Crazy Fish" : load("res://sound/music/song_files/main_level_matthew_c.tres"),
	"Coral Beef" : load("res://sound/music/song_files/main_level_matthew_p.tres"),
	"Fishing Hole Frolic" : load("res://sound/music/song_files/main_level_nathan.tres")
}

static var mapPool = [
	"res://world/catwalk/catwalk.tscn",
	"res://world/heightmap_test/heightmap_test.tscn",
	"res://world/level-coffin/level-coffin.tscn",
	"res://world/level-docks/level-docks.tscn",
	"res://world/catwalk/catwalk.tscn"
]

## The maximum time allowed for a round, in seconds.
@export var maximumRoundTime: int = 300
@export var minimumRoundTime: int = 180

@export_group("Default Settings")

# TODO: replace with names of actual maps
## The default maps selected for a round.
@export_flags("Map1","Map2","Map3","Map4","Map5")
var defaultMapSelect: int

## The default song selection for the round.
@export var defaultSongSelect: int = RANDOM_SONG
## The amount of time for each round by default, in seconds.
@export var defaultRoundTime: int = 180
## The default spawn rate for items.
@export var defaultItemSpawn: SpawnRate = SpawnRate.MEDIUM
## The default spawn rate for fish.
@export var defaultFishSpawn: SpawnRate = SpawnRate.MEDIUM

## The default selection of items spawned.
@export_flags("Rubber Mallet", "Butterfly Net", "Banana Peel", "Brick",
	"Glue Grenade", "Helmet", "Ziplock Bag", "Golden Worm")
var defaultItemSelect: int

enum Items {
	RUBBER_MALLET = 1,
	BUTTERFLY_NET = 2,
	BANANA_PEEL = 4,
	BRICK = 8,
	GLUE_GRENADE = 16,
	HELMET = 32,
	ZIPLOCK_BAG = 64,
	GOLDEN_WORM = 128
}

static var first_time : bool = true

## The current length of each round, in seconds.
static var roundTime: int = 180
## The current spawn rate of items (Low, Medium, or High).
static var itemSpawn: SpawnRate
## The current spawn rate of fish (Low, Medium, or High).
static var fishSpawn: SpawnRate
## The currently selected items to spawn in this game.
static var itemSelect: int
## The currently selected maps to use in this game.
static var mapSelect: int
## The ID of the currently selected song.
static var songSelect: int

@onready var panel: Control = $Background
@onready var timerInput: Label = %MinuteBox
@onready var fishRadios: Radios = %FishSpawnRateRadios
@onready var itemRadios: Radios = %ItemSpawnRateRadios
@onready var itemSelectList := %ItemSelection.find_children("*", "Button")
@onready var mapSelectList := %MapSelection.find_children("*", "TextureButton")
@onready var song_options: OptionButton = %SongOptions

@onready var more_time_button : Button = %MoreButton
@onready var less_time_button : Button = %LessButton

@onready var banana_item_sprite : ItemSprite = $Background/SettingsMenu/ItemSelection/HBoxContainer/BananaPeel/ItemSprite3

func set_greyed_out(node: Control, setting: bool) -> void:
	const param_name = "greyed_out"
	var mat := node.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter(param_name, setting)

func to_bin(n: int, min_bits: int = 8) -> String:
	if n == 0:
		return "0".repeat(min_bits)

	var ret := ""

	while n != 0:
		if n & 1: ret += "1"
		else: ret += "0"
		n >>= 1
	
	if ret.length() < min_bits:
		ret += "0".repeat(min_bits - ret.length())
	
	return ret.reverse()

func _ready() -> void:
	for entry : String in song_pool.keys():
		song_options.add_item(entry)
	
	#assert(song_options.item_count == music_pool.size() + 1, "Number of songs do not match options")
	
	if first_time:
		_on_reset_button_pressed()
		first_time = false

	if not get_tree().current_scene == self:
		hide()
	#panel.hide()
	panel.draw.connect(update_menu)

	for button: BaseButton in itemSelectList:
		button.pressed.connect(func():
			# update greyed out state
			itemSelect = get_bitmask_from_buttons(itemSelectList)
			Debug.log("itemSelect = ", to_bin(itemSelect))
			set_buttons_from_bitmask(itemSelectList, itemSelect)
		)

	for button: BaseButton in mapSelectList:
		button.pressed.connect(func():
			# update greyed out state
			mapSelect = get_bitmask_from_buttons(mapSelectList)
			Debug.log("itemSelect = ", to_bin(mapSelect))
			set_buttons_from_bitmask(mapSelectList, mapSelect)
		)

## Refreshes the menu with the current settings.
## This is called automatically when the panel becomes visible.
func update_menu() -> void:
	update_timer()
	itemRadios.set_value(itemSpawn)
	fishRadios.set_value(fishSpawn)
	set_buttons_from_bitmask(itemSelectList, itemSelect)
	set_buttons_from_bitmask(mapSelectList, mapSelect)
	song_options.select(song_options.get_item_index(songSelect))

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
	itemSpawn = itemRadios.get_value() as SpawnRate
	print("Item spawn rate: ",itemSpawn)
	fishSpawn = fishRadios.get_value() as SpawnRate

	# Selections
	itemSelect = get_bitmask_from_buttons(itemSelectList)
	mapSelect = get_bitmask_from_buttons(mapSelectList)
	songSelect = song_options.get_selected_id()
	print(roundTime)
	print(itemSpawn)
	print(fishSpawn)
	print(itemSelect)
	
	print("Maps" +str(String.num_int64(mapSelect,2)))
	print(songSelect)
	Multiplayer.set_map(String.num_int64(mapSelect,2),mapPool)

## Reset settings to default.
func _on_reset_button_pressed() -> void:
	roundTime = defaultRoundTime
	itemSpawn = defaultItemSpawn
	fishSpawn = defaultFishSpawn
	itemSelect = defaultItemSelect
	mapSelect = defaultMapSelect
	songSelect = defaultSongSelect
	
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
			var selected = bool(bitmask & 1)
			button.button_pressed = selected

			set_greyed_out(button, not selected)
			bitmask >>= 1

func open() -> void:
	if not multiplayer.is_server():
		return
	if BananaPeel.armadillo_mode:
		banana_item_sprite.visible_item = Item.Type.ARMADILLO
	else:
		banana_item_sprite.visible_item = Item.Type.BANANA_PEEL
	show()
	UIState.ui_state = UIState.State.LOBBY_SETTINGS

func close() -> void:
	if not multiplayer.is_server():
		return
	_on_save_button_pressed()
	hide()
	UIState.ui_state = UIState.State.NONE

func _on_timer_more_button_pressed() -> void:
	if (roundTime < maximumRoundTime):
		roundTime = clampi(roundTime + 30, minimumRoundTime, maximumRoundTime)
		less_time_button.disabled = false
	if (roundTime >= maximumRoundTime): more_time_button.disabled = true
	update_timer()

func _on_timer_less_button_pressed() -> void:
	if (roundTime > minimumRoundTime):
		roundTime = clampi(roundTime - 30, minimumRoundTime, maximumRoundTime)
		more_time_button.disabled = false
	if (roundTime <= minimumRoundTime): less_time_button.disabled = true
	update_timer()

func _on_minute_box_editing_toggled(toggled_on: bool) -> void:
	if toggled_on: return
	if timerInput.text.contains(":"):
		var timerText = timerInput.text.split(":")
		roundTime = int(timerText[0]) * 60 + int(timerText[1])
	else:
		roundTime = int(timerInput.text)
	roundTime = clampi(roundTime, minimumRoundTime, maximumRoundTime)
	update_timer()

func update_timer() -> void:
	@warning_ignore("integer_division")
	timerInput.text = "%d:%02d" % [roundTime / 60, roundTime % 60]
	
	less_time_button.disabled = roundTime <= minimumRoundTime
	more_time_button.disabled = roundTime >= maximumRoundTime

func _on_exit_button_pressed() -> void:
	close()

static func get_song_selection() -> String:
	var song_index : int
	if songSelect == RANDOM_SONG:
		song_index = randi_range(0,LobbySettings.song_pool.size() - 1)
	else:
		song_index = songSelect-1
	return song_pool.keys().get(song_index)
