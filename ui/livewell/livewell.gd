extends Node

var livewellInventory = []
@export var currentFish : String
@onready var livewellPanel : Panel = $Panel
@onready var fish : Label = $Panel/VBoxContainer/Fish

func addFish(fish : Fish) -> void:
	livewellInventory.append(fish)
	updateVisual()

func removeFish() -> void:
	livewellInventory.remove(0)
	updateVisual()
	
func updateVisual() -> void:
	currentFish = ""
	for fish in livewellInventory:
		currentFish = currentFish + fish.fish_name + "\n"  
	fish.text = currentFish
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		livewellPanel.visible = !livewellPanel.visible
