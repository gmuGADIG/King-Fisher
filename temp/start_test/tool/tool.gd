class_name Tool
extends Area2D

signal picked_up
signal dropped
signal used

static var held_tool: Tool

var in_use := false:
	set(v):
		if v and held_tool != null:
			return
		
		in_use = v
		if v:
			held_tool = self
			picked_up.emit()
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		else:
			held_tool = null
			dropped.emit()
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED

var hold_spot := Vector2()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		in_use = false

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:	
	if event.is_action_pressed("cast_rod"):
		get_viewport().set_input_as_handled()
		
		if in_use:
			used.emit()
		else:
			# this no-ops if tool_held = true
			in_use = true
			hold_spot = get_global_mouse_position() - get_parent().global_position

func _process(_delta: float) -> void:
	if in_use:
		get_parent().global_position = get_global_mouse_position() - hold_spot
