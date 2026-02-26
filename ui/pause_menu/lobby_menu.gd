extends Control

@export var roundTimer:int 
@export var itemSpawn:int
@export var fishSpawn:int
@export var itemSelect:String
@export var mapSelect:String
@export var musicSelect:String

@onready var timerSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Timer SpinBox"
@onready var itemSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Item Spawn SpinBox"
@onready var fishSpinBox:SpinBox = $"CanvasLayer/Panel/VBoxContainer/Fish Spawn SpinBox"
@onready var itemButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Item OptionButton"
@onready var mapButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Map OptionButton"
@onready var musicButton:OptionButton = $"CanvasLayer/Panel/VBoxContainer/Music OptionButton"





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
	
	
	
