class_name StorageSeat extends Node3D

@onready var interactable_area: Area3D = $InteractableArea
@onready var char_select_menu: CanvasLayer = $CharSelectUI
var player_texture_manager: PlayerTextureManager

func _on_interactable_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and player_texture_manager == null:
		player_texture_manager = body.get_node("PlayerTextureManager")

func _on_interactable_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and player_texture_manager:
		player_texture_manager = null

func _input(event: InputEvent) -> void:
	if event.is_action("scoreboard") and player_texture_manager:
		if player_texture_manager.is_multiplayer_authority():
			char_select_menu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_exit_button_pressed() -> void:
	char_select_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_player_texture(tex_index: int):
	player_texture_manager.texture_id = tex_index
