extends Node

signal new_player(id: int)

const PORT = 25575
const MAX_CLIENTS = 3

var player_list: Array[int] = []


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id: int) -> void:
	print("peer connected")
	player_list.push_back(id)
	new_player.emit(id)
	
	if multiplayer.is_server():
		learn_players.rpc_id(id, player_list)

@rpc("reliable")
func learn_players(new_player_list: Array[int]) -> void:
	for player in new_player_list:
		if not player in player_list:
			player_list.push_back(player)
			new_player.emit(player)


func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	

@rpc
func print_hello() -> void:
	print("hello")
