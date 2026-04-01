class_name CountdownLabel
extends Label

signal finished

@export var duration: int
@onready var format_string := text

func start():
	for current_count in range(duration, 0, -1):
		text = str(current_count)
		await get_tree().create_timer(1.).timeout
	
	finished.emit()
