class_name HangingFish
extends Button

@export var fish : Fish

func set_fish(fish : Fish) -> void:
	self.fish = fish
	$Fish_Image.texture = fish.sprite
