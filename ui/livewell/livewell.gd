extends Node

var livewellInventory = []
@export var currentFish : String

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
	$CanvasLayer/Panel/VBoxContainer/Fish.text = currentFish
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("livewell_menu"):
		$CanvasLayer/Panel.visible = !$CanvasLayer/Panel.visible
