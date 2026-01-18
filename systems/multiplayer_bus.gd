extends Node

const PORT = 25565
const MAX_CLIENTS = 3

func _ready() -> void:
	pass

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer

@rpc
func _process(delta: float) -> void:
	print("hello")
