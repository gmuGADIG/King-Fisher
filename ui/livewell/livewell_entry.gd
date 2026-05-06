extends Control
class_name LivewellEntry

@onready var size_ratio : Vector2 = size

@onready var background : Panel = $Background
@onready var fish_sprite : TextureRect = $Background/MarginContainer/FishSprite
@onready var points_label : Label = $Points
@onready var count_label : Label = $Count

func set_fish(fish : Fish, count : int) -> void:
	fish_sprite.texture = fish.sprite
	background.get_theme_stylebox("panel").set_bg_color(fish.grade_color())
	
	count_label.text = str(count)+"x"
	if count > 1:
		count_label.show()
	else:
		count_label.hide()
	
	points_label.text = str(fish.get_score()) + " pts"
