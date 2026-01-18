extends Node2D

func _ready() -> void:
	Multiplayer.new_player.connect(on_player_join)
	spawn_player.rpc(1, Color.WHITE, Vector2(150, randf_range(100, 500)))
	print("ready!!")
		#spawn_player.rpc(Multiplayer.player_list[0], Color.YELLOW, Vector2(800, randf_range(100, 500)), -1)

func on_player_join(id : int) -> void:
	for player_id in Multiplayer.player_list:
		if player_id != id:
			spawn_player.rpc_id(id,player_id,Color.WHITE,Vector2(150, randf_range(100, 500)))
	spawn_player.rpc(id,Color.WHITE,Vector2(150, randf_range(100, 500)))

@rpc("reliable", "call_local")
func spawn_player(id: int, color: Color, pos: Vector2) -> void:
	var player: Player = preload("res://player.tscn").instantiate()
	player.set_multiplayer_authority(id)
	player.modulate = color
	player.position = pos
	
	add_child(player)

func print_players() -> void:
	if multiplayer.is_server():
		print("players:")
		for player_id in Multiplayer.player_list:
			print(player_id)
