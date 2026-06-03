extends Resource
class_name LoopInfo

@export var loop_start: float
@export var loop_end: float
@export var fade_period: float = 0.2
@export var fade_in_curve: Curve
@export var fade_out_curve: Curve

func _init(l_start: float = 0.0, l_end: float = 0.0, f_period: float = 0.2) -> void:
	loop_start = l_start
	loop_end = l_end
	fade_period = f_period
	
	# Default smooth fade in (0,0) -> (1,1) with easing
	fade_in_curve = Curve.new()
	fade_in_curve.add_point(Vector2(0, 0), 0.0, 1.0)
	fade_in_curve.add_point(Vector2(1, 1), 1.0, 0.0)
	
	# Default smooth fade out (0,1) -> (1,0) with easing
	fade_out_curve = Curve.new()
	fade_out_curve.add_point(Vector2(0, 1), 0.0, -1.0)
	fade_out_curve.add_point(Vector2(1, 0), -1.0, 0.0)
