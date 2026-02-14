extends Item

func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("My name is item_test_2 and I'm just O.K. That's all. Take care.")
		queue_free()
