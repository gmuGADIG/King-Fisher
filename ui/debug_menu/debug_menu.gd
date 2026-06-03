extends CanvasLayer

var old_mouse_mode: Input.MouseMode

func open_debug_menu() -> void:
	old_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	%PanelContainer.show()

func close_debug_menu() -> void:
	hide()
	%PanelContainer.hide()
	Input.mouse_mode = old_mouse_mode

func _ready() -> void:
	hide()
	%PanelContainer.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		if visible:
			close_debug_menu()
		else:
			open_debug_menu()

func _on_close_button_pressed() -> void:
	close_debug_menu()

func _on_sushi_spawner_button_pressed(index: int) -> void:
	for player: Player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			var new_fish = Fish.create(Fish.Grade.SUSHI, index)
			player.give_fish(new_fish)
			print("Gave a %s to Player %d!" % [new_fish.fish_name, player.get_multiplayer_authority()])
			break
