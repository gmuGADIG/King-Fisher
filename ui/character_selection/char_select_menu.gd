class_name CharacterSelectionMenu extends Control

var character_textures: Array[Texture2D]
var current_tex: int = -1
@export var storage_seat_parent: StorageSeat
@onready var character_buttons := $HBoxContainer/GridContainer.get_children()
@onready var demo_character_texture: PlayerTextureManager = %DemoCharacterTexture

func _become_visible(source: Node) -> void:
	if not source.visible: return
	character_textures = storage_seat_parent.player_texture_manager.player_textures
	for i in range(0, clampi(character_textures.size(), 0, 4)):
		character_buttons[i].texture_normal = character_textures[i]
		character_buttons[i].show()
		character_buttons[i].pressed.connect(_on_character_texture_selected.bind(i))

func _on_character_texture_selected(tex_index: int) -> void:
	demo_character_texture.texture_id = tex_index
	current_tex = tex_index

func _on_confirm_button_pressed() -> void:
	if current_tex in range(0, character_textures.size()):
		storage_seat_parent.set_player_texture(current_tex)
		storage_seat_parent._on_exit_button_pressed()
