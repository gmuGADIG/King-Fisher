extends Node

var texture_id := 1:
	set(v):
		texture_id = clampi(v, 0, player_textures.size() - 1)
		_update_player_texture()

@export var player_textures: Array[Texture2D]
@export var target_mesh: MeshInstance3D
@onready var mat := target_mesh.material_override as StandardMaterial3D

func _update_player_texture() -> void:
	mat.albedo_texture = player_textures[texture_id]

func _ready() -> void:
	assert(not player_textures.is_empty())

	# BUG: this is NOT going to be synced between clients, and frankly, i don't care
	# i just need something to show to art team
	texture_id = randi_range(0, player_textures.size() - 1)

	_update_player_texture()

