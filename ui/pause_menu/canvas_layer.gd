extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	print("1")
	if event.is_action_pressed("Pause"):
		print("2")
		if visible == false:
			show()
		else:
			hide()


# weoweoeoweoweowowow
