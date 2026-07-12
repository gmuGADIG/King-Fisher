@tool
class_name CarouselContainer
extends Container

signal node_selected(node : Node)

@export var current_selected : int = 0:
	set(val):
		#if moving:
			#return
		
		if val < 0:
			val = 0
		if val >= get_child_count():
			val = get_child_count()-1
		current_selected = val
		
		if Engine.is_editor_hint():
			tween_selected = current_selected
			print("sorting")
			queue_sort()
@export var fade_strength : float = 1.0
@export var tween_time : float = 0.3
@export var tween_type : Tween.TransitionType = Tween.TRANS_CUBIC

var tween_selected : float:
	set(val):
		tween_selected = val
		queue_sort()

var moving : bool = false

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		for i in get_child_count():
			var c = get_child(i)
			var dist_from_selected : float = i-tween_selected
			
			if i == current_selected:
				c.process_mode = Node.PROCESS_MODE_INHERIT
			else:
				c.process_mode = PROCESS_MODE_DISABLED
			
			if c is Control:
				c.modulate.a = clampf(1.1-absf(fade_strength*dist_from_selected),0,1)
			# Fit to own size
			fit_child_in_rect(c, Rect2(Vector2(dist_from_selected*size.x,0), size))
			#c.position.x += (i-current_selected)*size.x

func right() -> void:
	if current_selected+1 >= get_child_count():
		return
	
	current_selected += 1
	node_selected.emit(get_child(current_selected))
	_move_to_target()

func left() -> void:
	if current_selected-1 < 0:
		return
		
	current_selected -= 1
	node_selected.emit(get_child(current_selected))
	_move_to_target()


func _move_to_target() -> void:
	moving = true
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(tween_type)
	tween.tween_property(self,"tween_selected",current_selected,tween_time)
	await tween.finished
	moving = false
