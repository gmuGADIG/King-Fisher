extends Resource
class_name Section

## Name/label for this section (e.g., "intro", "main_loop", "climax")
@export var section_name: String = ""
@export var section_start: float = 0.0
@export var section_end: float = 0.0
## If true, this section will loop back to section_start when reaching section_end
@export var loop: bool = false
@export var fade_period: float = 0.2
@export var fade_in_curve: Curve
@export var fade_out_curve: Curve

func _init(
	p_name: String = "",
	p_start: float = 0.0,
	p_end: float = 0.0,
	p_loop: bool = false,
	p_fade_period: float = 0.2
) -> void:
	section_name = p_name
	section_start = p_start
	section_end = p_end
	loop = p_loop
	fade_period = p_fade_period
	
	# Default smooth fade in (0,0) -> (1,1) with easing
	fade_in_curve = Curve.new()
	fade_in_curve.add_point(Vector2(0, 0), 0.0, 1.0)
	fade_in_curve.add_point(Vector2(1, 1), 1.0, 0.0)
	
	# Default smooth fade out (0,1) -> (1,0) with easing
	fade_out_curve = Curve.new()
	fade_out_curve.add_point(Vector2(0, 1), 0.0, -1.0)
	fade_out_curve.add_point(Vector2(1, 0), -1.0, 0.0)

## Returns the duration of this section
func get_duration() -> float:
	return section_end - section_start
