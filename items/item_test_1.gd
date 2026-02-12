extends Item

func use() -> void:
	if !is_held: print("Item was used while not held, WTF?")
	else:
		print("I'm item_test_1!! I'm fuckin awesome!!!")
		queue_free()
