extends Item

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("I'm item_test_1!! I'm fuckin awesome!!!")
		queue_free()
