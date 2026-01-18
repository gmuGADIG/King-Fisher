extends Node

signal new_player(id: int)

const PORT = 25575
const MAX_CLIENTS = 3


var allow_connections : bool = true

var player_list: Dictionary[int,String] = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id: int) -> void:
	Debug.log("on peer connect")
	if not multiplayer.is_server():
		return
	
	Debug.log("peer ",id," connected")
	player_list.set(id,"Player")
	new_player.emit(id)
	learn_players.rpc_id(id, player_list)

@rpc("reliable")
func learn_players(new_player_list: Dictionary[int,String]) -> void:
	for player in new_player_list:
		if not player in player_list:
			player_list.set(player,"Player")
			new_player.emit(player)


func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	player_list.set(1,"Player")
	

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	player_list.set(multiplayer.get_unique_id(),"Player")
	
