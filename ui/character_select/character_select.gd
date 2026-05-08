extends Control

@export var character_textures : Array[Texture]

@export var spin_speed : float = 1.0
@export var player_mesh : MeshInstance3D

var selected_skin : int

@onready var mat := player_mesh.material_override as StandardMaterial3D

func _ready() -> void:
	hide()

func open() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_mesh.rotate(Vector3.FORWARD,delta * spin_speed)


func _on_character_selected(skin_index: int) -> void:
	mat.albedo_texture = character_textures[skin_index]
	selected_skin = skin_index


func _on_confirm_button_pressed() -> void:
	assign_skin.rpc(multiplayer.get_unique_id(),selected_skin)
	Multiplayer.player_list[multiplayer.get_unique_id()].player.block_player_inputs = false
	close()

@rpc("reliable","any_peer","call_local")
func assign_skin(player_id : int, skin_index : int) -> void:
	Multiplayer.player_list[player_id].character_texture_id = skin_index
	var mat : StandardMaterial3D = Multiplayer.player_list[player_id].player.player_mesh.mesh.material_override as StandardMaterial3D
	mat.albedo_texture = character_textures[skin_index]
