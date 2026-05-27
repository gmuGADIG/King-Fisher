extends Control

@export var character_textures : Array[Texture]

@export var spin_speed : float = 1.0
@export var player_mesh : MeshInstance3D

var selected_skin : int

@onready var mat := player_mesh.material_override as StandardMaterial3D

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and UIState.ui_state == UIState.State.CHARACTER_SELECT:
		close()

func open() -> void:
	show()
	UIState.ui_state = UIState.State.CHARACTER_SELECT
	var current_tex_id : int = Multiplayer.player_list[get_multiplayer_authority()].character_texture_id
	mat.albedo_texture = character_textures[current_tex_id]

func close() -> void:
	hide()
	UIState.ui_state = UIState.State.NONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_mesh.rotate(Vector3.FORWARD,delta * spin_speed)


func _on_character_selected(skin_index: int) -> void:
	mat.albedo_texture = character_textures[skin_index]
	selected_skin = skin_index


func _on_confirm_button_pressed() -> void:
	assign_skin.rpc(multiplayer.get_unique_id(),selected_skin)
	close()

func pick_random_texture_index() -> int:
	return randi_range(0,character_textures.size()-1)


@rpc("reliable","any_peer","call_local")
func assign_skin(player_id : int, skin_index : int) -> void:
	Multiplayer.player_list[player_id].character_texture_id = skin_index
	var mat : StandardMaterial3D = Multiplayer.player_list[player_id].player.player_mesh.mesh.material_override as StandardMaterial3D
	mat.albedo_texture = character_textures[skin_index]
