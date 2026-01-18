extends Node2D

func _ready() -> void:
	Multiplayer.new_player.connect(on_player_join)
	if multiplayer.is_server():
		spawn_player.rpc(1, Color.WHITE, Vector2(150, randf_range(100, 500)))
		$CanvasLayer/VBoxContainer/Label.text = "Server"
	else:
		$CanvasLayer/VBoxContainer/Label.text = "Client"

func on_player_join(id : int) -> void:
	if not multiplayer.is_server():
		return
		
	for player_id in Multiplayer.player_list:
		if player_id != id:
			spawn_player.rpc_id(id,player_id,Color.WHITE,Vector2(150, randf_range(100, 500)))
	spawn_player.rpc(id,Color.WHITE,Vector2(150, randf_range(100, 500)))

@rpc("reliable", "call_local")
func spawn_player(id: int, color: Color, pos: Vector2) -> void:
	Debug.log("Creating player of id ",id)
	var player: Player = preload("res://player.tscn").instantiate()
	player.set_multiplayer_authority(id)
	player.modulate = color
	player.position = pos
	
	add_child(player)
