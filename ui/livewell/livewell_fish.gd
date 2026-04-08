extends Node
class_name LivewellFish

var fish_file_path : String
var fish_info : livewell_fish_info

@onready var background : Panel = $Background
@onready var fish_sprite : TextureRect = $Background/FishSprite
@onready var points_label : Label = $Points
@onready var underline_points : ColorRect = $PointsUnderline
@onready var count : Label = $Count

func _ready() -> void:
	count.visible = false

func set_fish(path : String, info : livewell_fish_info) -> void:
	self.fish_file_path = path
	self.fish_info = info
	load_fish.call_deferred()
	
func load_fish() -> void:
	fish_sprite.texture = load(fish_file_path)
	background.get_theme_stylebox("panel").set_bg_color(get_fish_color())
	points_label.text = str(fish_info.fish.get_score()) + " pts"
	underline_points.size.x = get_text_pixel_width(points_label.text, points_label) * 1.25
	underline_points.position.x = points_label.position.x + (points_label.size.x / 2) - (underline_points.size.x / 2)

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

func get_text_pixel_width(text: String, label_node: Label) -> float:
	var font = label_node.get_theme_font("font")
	var font_size = label_node.get_theme_font_size("font_size")

	var size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	return size.x
