extends Item

func use() -> void:
	if !is_held: print("Item was used while not held, WTF?")
	else:
		print("My name is item_test_2 and I'm just O.K. That's all. Take care.")
		queue_free()
