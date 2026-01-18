extends Node

const PORT = 25565
const MAX_CLIENTS = 3
var in_game : bool = false

func _ready() -> void:
	pass

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	in_game = true

func join_server(ip : String, port : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = peer
	in_game = true

func _input(event: InputEvent) -> void:
	if in_game and multiplayer.is_server() and event.is_action_pressed("ui_accept"):
		print_hello()

@rpc
func print_hello() -> void:
	print("hello")
