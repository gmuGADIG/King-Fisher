extends Control
class_name SongCurveEditor

## A simple visual curve editor for crossfade curves.
## Allows clicking to add points and dragging to move them.
## Right-click to remove points.
## Click a point to select it and show tangent handles for editing.

signal curve_changed

const POINT_RADIUS: float = 6.0
const POINT_HIT_RADIUS: float = 12.0
const LINE_WIDTH: float = 2.0
const GRID_LINES: int = 4
const PLAYHEAD_WIDTH: float = 2.0
const PADDING: float = 8.0  # Internal padding so points don't clip outside bounds

# Tangent handle settings
const TANGENT_HANDLE_RADIUS: float = 5.0
const TANGENT_HANDLE_HIT_RADIUS: float = 10.0
const TANGENT_LINE_WIDTH: float = 1.5
const TANGENT_HANDLE_DISTANCE: float = 50.0  # Screen pixels from point to tangent handle

const COLOR_BG := Color(0.08, 0.08, 0.1, 1.0)
const COLOR_GRID := Color(0.15, 0.15, 0.18, 1.0)
const COLOR_CURVE := Color(0.4, 0.7, 0.5, 1.0)
const COLOR_POINT := Color(0.9, 0.9, 0.9, 1.0)
const COLOR_POINT_HOVER := Color(1.0, 0.9, 0.5, 1.0)
const COLOR_POINT_DRAG := Color(0.5, 0.9, 0.6, 1.0)
const COLOR_POINT_SELECTED := Color(0.6, 0.85, 1.0, 1.0)
const COLOR_BORDER := Color(0.2, 0.2, 0.22, 1.0)
const COLOR_PLAYHEAD := Color(1.0, 0.9, 0.4, 0.9)
const COLOR_PLAYHEAD_DOT := Color(1.0, 0.95, 0.6, 1.0)
const COLOR_TANGENT_LINE := Color(0.5, 0.5, 0.6, 0.7)
const COLOR_TANGENT_HANDLE := Color(0.8, 0.6, 0.3, 1.0)
const COLOR_TANGENT_HANDLE_HOVER := Color(1.0, 0.8, 0.4, 1.0)
const COLOR_TANGENT_HANDLE_DRAG := Color(1.0, 0.6, 0.2, 1.0)

enum TangentSide { NONE, LEFT, RIGHT }

var curve: Curve:
	set(value):
		curve = value
		_selected_point = -1
		queue_redraw()

## Playhead position for visualizing crossfade progress (0.0 to 1.0, -1 = hidden)
var playhead_position: float = -1.0:
	set(value):
		playhead_position = value
		queue_redraw()

var _hovered_point: int = -1
var _dragging_point: int = -1
var _selected_point: int = -1  # Point currently selected for tangent editing
var _hovered_tangent: TangentSide = TangentSide.NONE
var _dragging_tangent: TangentSide = TangentSide.NONE

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(100, 60)
	
	# Create default curve if none
	if not curve:
		curve = Curve.new()
		curve.add_point(Vector2(0, 0))
		curve.add_point(Vector2(1, 1))

func _draw() -> void:
	var full_rect := Rect2(Vector2.ZERO, size)
	var curve_rect := _get_curve_rect()
	
	# Background (full area)
	draw_rect(full_rect, COLOR_BG, true)
	
	# Grid lines (within curve area)
	for i in range(1, GRID_LINES):
		var t := float(i) / GRID_LINES
		var x := curve_rect.position.x + t * curve_rect.size.x
		var y := curve_rect.position.y + t * curve_rect.size.y
		draw_line(Vector2(x, curve_rect.position.y), Vector2(x, curve_rect.end.y), COLOR_GRID, 1.0)
		draw_line(Vector2(curve_rect.position.x, y), Vector2(curve_rect.end.x, y), COLOR_GRID, 1.0)
	
	# Border (around curve area)
	draw_rect(curve_rect, COLOR_BORDER, false, 1.0)
	
	if not curve:
		return
	
	# Draw curve line
	var prev_pos := _curve_to_screen(Vector2(0, curve.sample(0)))
	var steps := int(curve_rect.size.x / 2)
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var val := curve.sample(t)
		var pos := _curve_to_screen(Vector2(t, val))
		draw_line(prev_pos, pos, COLOR_CURVE, LINE_WIDTH, true)
		prev_pos = pos
	
	# Draw tangent handles for selected point
	if _selected_point >= 0 and _selected_point < curve.point_count:
		_draw_tangent_handles(_selected_point)
	
	# Draw points
	for i in range(curve.point_count):
		var pt := curve.get_point_position(i)
		var screen_pos := _curve_to_screen(pt)
		
		var color := COLOR_POINT
		var radius := POINT_RADIUS
		
		if i == _dragging_point:
			color = COLOR_POINT_DRAG
			radius = POINT_RADIUS * 1.3
		elif i == _selected_point:
			color = COLOR_POINT_SELECTED
			radius = POINT_RADIUS * 1.2
		elif i == _hovered_point:
			color = COLOR_POINT_HOVER
			radius = POINT_RADIUS * 1.2
		
		draw_circle(screen_pos, radius, color)
		draw_arc(screen_pos, radius, 0, TAU, 16, COLOR_BORDER, 1.0)
	
	# Draw playhead if active
	if playhead_position >= 0.0 and playhead_position <= 1.0:
		var playhead_screen := _curve_to_screen(Vector2(playhead_position, 0))
		var curve_val := curve.sample(playhead_position)
		var dot_pos := _curve_to_screen(Vector2(playhead_position, curve_val))
		
		# Vertical line (within curve area)
		draw_line(Vector2(playhead_screen.x, curve_rect.position.y), Vector2(playhead_screen.x, curve_rect.end.y), COLOR_PLAYHEAD, PLAYHEAD_WIDTH)
		
		# Dot on the curve showing current value
		draw_circle(dot_pos, POINT_RADIUS * 1.4, COLOR_PLAYHEAD_DOT)
		draw_arc(dot_pos, POINT_RADIUS * 1.4, 0, TAU, 16, COLOR_PLAYHEAD, 1.5)

func _draw_tangent_handles(point_idx: int) -> void:
	var pt := curve.get_point_position(point_idx)
	var screen_pos := _curve_to_screen(pt)
	
	var left_tangent := curve.get_point_left_tangent(point_idx)
	var right_tangent := curve.get_point_right_tangent(point_idx)
	
	# Draw left tangent (only if not first point)
	if point_idx > 0:
		var left_handle_pos := _get_tangent_handle_screen_pos(screen_pos, left_tangent, true)
		
		# Draw line from point to handle
		draw_line(screen_pos, left_handle_pos, COLOR_TANGENT_LINE, TANGENT_LINE_WIDTH)
		
		# Draw handle
		var left_color := COLOR_TANGENT_HANDLE
		if _dragging_tangent == TangentSide.LEFT:
			left_color = COLOR_TANGENT_HANDLE_DRAG
		elif _hovered_tangent == TangentSide.LEFT:
			left_color = COLOR_TANGENT_HANDLE_HOVER
		
		draw_circle(left_handle_pos, TANGENT_HANDLE_RADIUS, left_color)
		draw_arc(left_handle_pos, TANGENT_HANDLE_RADIUS, 0, TAU, 12, COLOR_BORDER, 1.0)
	
	# Draw right tangent (only if not last point)
	if point_idx < curve.point_count - 1:
		var right_handle_pos := _get_tangent_handle_screen_pos(screen_pos, right_tangent, false)
		
		# Draw line from point to handle
		draw_line(screen_pos, right_handle_pos, COLOR_TANGENT_LINE, TANGENT_LINE_WIDTH)
		
		# Draw handle
		var right_color := COLOR_TANGENT_HANDLE
		if _dragging_tangent == TangentSide.RIGHT:
			right_color = COLOR_TANGENT_HANDLE_DRAG
		elif _hovered_tangent == TangentSide.RIGHT:
			right_color = COLOR_TANGENT_HANDLE_HOVER
		
		draw_circle(right_handle_pos, TANGENT_HANDLE_RADIUS, right_color)
		draw_arc(right_handle_pos, TANGENT_HANDLE_RADIUS, 0, TAU, 12, COLOR_BORDER, 1.0)

func _get_tangent_handle_screen_pos(point_screen_pos: Vector2, tangent: float, is_left: bool) -> Vector2:
	# Tangent is the slope (dy/dx in curve space)
	# In curve space: positive tangent = going up as x increases
	# In screen space: y is inverted
	
	var rect := _get_curve_rect()
	
	# In curve space, direction for tangent t going right is (1, t)
	# For left handle, we go the opposite direction: (-1, -t)
	var curve_dir := Vector2(1.0, tangent) if not is_left else Vector2(-1.0, -tangent)
	
	# Convert curve direction to screen direction
	# screen_dx = curve_dx * width
	# screen_dy = -curve_dy * height (y is flipped)
	var screen_dir := Vector2(
		curve_dir.x * rect.size.x,
		-curve_dir.y * rect.size.y
	)
	
	screen_dir = screen_dir.normalized() * TANGENT_HANDLE_DISTANCE
	return point_screen_pos + screen_dir

func _get_tangent_from_handle_pos(point_screen_pos: Vector2, handle_screen_pos: Vector2, is_left: bool) -> float:
	var rect := _get_curve_rect()
	var delta := handle_screen_pos - point_screen_pos
	
	# Convert screen delta to curve delta
	# curve_dx = screen_dx / width
	# curve_dy = -screen_dy / height (y is flipped)
	var curve_dx := delta.x / rect.size.x
	var curve_dy := -delta.y / rect.size.y
	
	# For left handle, we're measuring from the opposite direction
	# so flip the curve delta to get the actual tangent direction
	if is_left:
		curve_dx = -curve_dx
		curve_dy = -curve_dy
	
	# Handle near-vertical tangents (when handle is almost directly above/below point)
	if abs(curve_dx) < 0.001:
		if abs(curve_dy) < 0.001:
			return 0.0
		return 10.0 if curve_dy > 0 else -10.0
	
	# If handle is on the wrong side (negative curve_dx), clamp to small positive
	# This prevents tangent from flipping wildly when dragging across the point
	if curve_dx < 0:
		curve_dx = 0.001
	
	var tangent := curve_dy / curve_dx
	return clampf(tangent, -10.0, 10.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# First check if clicking on a tangent handle of the selected point
			if _selected_point >= 0:
				var tangent_side := _get_tangent_handle_at(event.position, _selected_point)
				if tangent_side != TangentSide.NONE:
					_dragging_tangent = tangent_side
					mouse_default_cursor_shape = Control.CURSOR_DRAG
					queue_redraw()
					return
			
			var point_idx := _get_point_at(event.position)
			if point_idx >= 0:
				if point_idx == _selected_point:
					# Already selected, start dragging
					_dragging_point = point_idx
					mouse_default_cursor_shape = Control.CURSOR_DRAG
				else:
					# Select this point (shows tangent handles)
					_selected_point = point_idx
					_dragging_point = point_idx
					mouse_default_cursor_shape = Control.CURSOR_DRAG
			else:
				# Clicked on empty space - deselect and add new point
				_selected_point = -1
				var curve_pos := _screen_to_curve(event.position)
				curve_pos.x = clampf(curve_pos.x, 0.0, 1.0)
				curve_pos.y = clampf(curve_pos.y, 0.0, 1.0)
				var new_idx := curve.add_point(curve_pos)
				_selected_point = new_idx  # Select the newly added point
				curve_changed.emit()
			queue_redraw()
		else:
			# End drag
			if _dragging_tangent != TangentSide.NONE:
				_dragging_tangent = TangentSide.NONE
				_hovered_tangent = _get_tangent_handle_at(event.position, _selected_point) if _selected_point >= 0 else TangentSide.NONE
			_dragging_point = -1
			_hovered_point = _get_point_at(event.position)
			_update_cursor()
			queue_redraw()
	
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var point_idx := _get_point_at(event.position)
			# Don't remove first or last point
			if point_idx > 0 and point_idx < curve.point_count - 1:
				if point_idx == _selected_point:
					_selected_point = -1
				elif _selected_point > point_idx:
					_selected_point -= 1
				curve.remove_point(point_idx)
				_hovered_point = -1
				_hovered_tangent = TangentSide.NONE
				_update_cursor()
				curve_changed.emit()
				queue_redraw()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# Handle tangent dragging
	if _dragging_tangent != TangentSide.NONE and _selected_point >= 0:
		var pt := curve.get_point_position(_selected_point)
		var point_screen_pos := _curve_to_screen(pt)
		var new_tangent := _get_tangent_from_handle_pos(point_screen_pos, event.position, _dragging_tangent == TangentSide.LEFT)
		
		if _dragging_tangent == TangentSide.LEFT:
			curve.set_point_left_tangent(_selected_point, new_tangent)
		else:
			curve.set_point_right_tangent(_selected_point, new_tangent)
		
		curve_changed.emit()
		queue_redraw()
		return
	
	if _dragging_point >= 0:
		# Convert mouse position directly to curve coordinates
		var curve_pos := _screen_to_curve(event.position)
		
		# Clamp Y position
		curve_pos.y = clampf(curve_pos.y, 0.0, 1.0)
		
		# Handle X position based on which point we're dragging
		var is_first := _dragging_point == 0
		var is_last := _dragging_point == curve.point_count - 1
		
		if is_first or is_last:
			# End points: only update Y, X is fixed at 0 or 1
			curve.set_point_value(_dragging_point, curve_pos.y)
		else:
			# Middle points: can move in both X and Y
			var prev_x := curve.get_point_position(_dragging_point - 1).x
			var next_x := curve.get_point_position(_dragging_point + 1).x
			curve_pos.x = clampf(curve_pos.x, prev_x + 0.01, next_x - 0.01)
			
			# set_point_offset returns new index since points are sorted by x
			var new_idx := curve.set_point_offset(_dragging_point, curve_pos.x)
			if new_idx != _dragging_point:
				if _selected_point == _dragging_point:
					_selected_point = new_idx
				_dragging_point = new_idx
			curve.set_point_value(_dragging_point, curve_pos.y)
		
		curve_changed.emit()
		queue_redraw()
	else:
		# Update hover state for tangent handles first (if a point is selected)
		var new_tangent_hover := TangentSide.NONE
		if _selected_point >= 0:
			new_tangent_hover = _get_tangent_handle_at(event.position, _selected_point)
		
		if new_tangent_hover != _hovered_tangent:
			_hovered_tangent = new_tangent_hover
			_update_cursor()
			queue_redraw()
		
		# Update hover state for points
		var new_hover := _get_point_at(event.position)
		if new_hover != _hovered_point:
			_hovered_point = new_hover
			_update_cursor()
			queue_redraw()

func _get_point_at(screen_pos: Vector2) -> int:
	if not curve:
		return -1
	
	for i in range(curve.point_count):
		var pt := curve.get_point_position(i)
		var pt_screen := _curve_to_screen(pt)
		if screen_pos.distance_to(pt_screen) < POINT_HIT_RADIUS:
			return i
	
	return -1

func _get_tangent_handle_at(screen_pos: Vector2, point_idx: int) -> TangentSide:
	if not curve or point_idx < 0 or point_idx >= curve.point_count:
		return TangentSide.NONE
	
	var pt := curve.get_point_position(point_idx)
	var point_screen_pos := _curve_to_screen(pt)
	
	# Check left tangent handle (only if not first point)
	if point_idx > 0:
		var left_tangent := curve.get_point_left_tangent(point_idx)
		var left_handle_pos := _get_tangent_handle_screen_pos(point_screen_pos, left_tangent, true)
		if screen_pos.distance_to(left_handle_pos) < TANGENT_HANDLE_HIT_RADIUS:
			return TangentSide.LEFT
	
	# Check right tangent handle (only if not last point)
	if point_idx < curve.point_count - 1:
		var right_tangent := curve.get_point_right_tangent(point_idx)
		var right_handle_pos := _get_tangent_handle_screen_pos(point_screen_pos, right_tangent, false)
		if screen_pos.distance_to(right_handle_pos) < TANGENT_HANDLE_HIT_RADIUS:
			return TangentSide.RIGHT
	
	return TangentSide.NONE

func _get_curve_rect() -> Rect2:
	# The area where the curve is drawn, inset by padding
	return Rect2(
		Vector2(PADDING, PADDING),
		Vector2(size.x - PADDING * 2, size.y - PADDING * 2)
	)

func _curve_to_screen(curve_pos: Vector2) -> Vector2:
	var rect := _get_curve_rect()
	return Vector2(
		rect.position.x + curve_pos.x * rect.size.x,
		rect.position.y + (1.0 - curve_pos.y) * rect.size.y
	)

func _screen_to_curve(screen_pos: Vector2) -> Vector2:
	var rect := _get_curve_rect()
	return Vector2(
		(screen_pos.x - rect.position.x) / rect.size.x,
		1.0 - (screen_pos.y - rect.position.y) / rect.size.y
	)

func _update_cursor() -> void:
	if _dragging_point >= 0 or _dragging_tangent != TangentSide.NONE:
		mouse_default_cursor_shape = Control.CURSOR_DRAG
	elif _hovered_tangent != TangentSide.NONE:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif _hovered_point >= 0:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

# Public API
func set_curve(new_curve: Curve) -> void:
	curve = new_curve
	_selected_point = -1
	_hovered_tangent = TangentSide.NONE
	_dragging_tangent = TangentSide.NONE
	queue_redraw()

func set_playhead(pos: float) -> void:
	playhead_position = pos
