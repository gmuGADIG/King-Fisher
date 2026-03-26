class_name LobbySettings
extends Control


@export var defaultRoundTimer:int 
@export var defaultItemSpawn:int
@export var defaultFishSpawn:int
@export var defaultItemSelect:String
@export var defaultMapSelect:String
@export var defaultMusicSelect:String

static var roundTimer:int
static var itemSpawn:int
static var fishSpawn:int
static var itemSelect:String
static var mapSelect:String
static var musicSelect:String



@onready var timerSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Timer SpinBox"
@onready var itemSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Item Spawn SpinBox"
@onready var fishSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Fish Spawn SpinBox"
@onready var itemButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Item OptionButton"
@onready var mapButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Map OptionButton"
@onready var musicButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Music OptionButton"

func _ready() -> void:
	$CanvasLayer/Panel.hide()


func _on_save_button_pressed() -> void:
	roundTimer = int(timerSpinBox.value)
	itemSpawn = int(itemSpinBox.value)
	fishSpawn = int(fishSpinBox.value)
	itemSelect = itemButton.get_item_text(itemButton.get_selected())
	mapSelect = mapButton.get_item_text(mapButton.get_selected())
	musicSelect = musicButton.get_item_text(musicButton.get_selected())
	print(roundTimer)
	print(itemSpawn)
	print(fishSpawn)
	print(itemSelect)
	print(mapSelect)
	print(musicSelect)
	
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("Menu") && multiplayer.is_server()):
		if($CanvasLayer/Panel.visible):
			print("Hiding menu!")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			print("Showing menu")
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		print("Menu pressed")
		print("Authority checked")
		$CanvasLayer/Panel.visible = !$CanvasLayer/Panel.visible
	


func _on_return_button_pressed() -> void:
	$CanvasLayer/Panel.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
