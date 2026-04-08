extends Node
class_name LivewellFish

var fish_file_path : String
var fish_info : livewell_fish_info

@onready var background : Panel = $Background
@onready var fish_sprite : TextureRect = $Background/FishSprite

func set_fish(path : String, info : livewell_fish_info) -> void:
	self.fish_file_path = path
	self.fish_info = info

func get_fish_color() -> Color:
	match fish_info.fish.grade:
		Fish.Grade.LEFTOVERS:
			return Color.WHITE # Gray
		Fish.Grade.FRESH:
			return Color.GREEN # Green
		Fish.Grade.PREMIUM:
			return Color.PURPLE # Purple
		Fish.Grade.SUSHI:
			return Color.GOLD # Gold
		_:
			return Color.WHITE # White for Unset or unknown grades

func _process(_delta: float) -> void:
	if fish_info != null:
		fish_sprite.texture = load(fish_file_path)
		background.get_theme_stylebox("panel").set_bg_color(get_fish_color())
	return
