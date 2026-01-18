extends Node2D

func _ready() -> void:
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		spawn_player.rpc(1, Color.WHITE, Vector2(150, randf_range(100, 500)), 1)
		#spawn_player.rpc(Multiplayer.player_list[0], Color.YELLOW, Vector2(800, randf_range(100, 500)), -1)

func on_player_join(id : int) -> void:
	spawn_player(id, Color.YELLOW, Vector2(150, randf_range(100, 500)), -1)
	pass

@rpc("reliable", "call_local")
func spawn_player(id: int, color: Color, pos: Vector2, punch_dir: float) -> void:
	var player: Player = preload("res://player.tscn").instantiate()
	player.set_multiplayer_authority(id)
	player.modulate = color
	player.position = pos
	player.punch_direction = punch_dir
	
	add_child(player)
