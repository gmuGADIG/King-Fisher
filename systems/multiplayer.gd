extends Node

signal new_player(id: int)
signal found_server(ip: String, name: String)

const PORT = 25575
const MAX_CLIENTS = 3
const SCAN_MSG = "iwannaplay"

var allow_connections : bool = true
var player_list: Dictionary[int,String] = {}

var scan_server: UDPServer
var scan_for_servers := true
var scan_client: PacketPeerUDP

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	scan_client = PacketPeerUDP.new()

func _process_scan_server() -> void:
	scan_server.poll()
	if scan_server.is_connection_available():
		Debug.log("heard a scan packet")
		var peer := scan_server.take_connection()
		if peer.get_var(0) == SCAN_MSG:
			Debug.log("sending something to the client.")
			peer.put_var("icanplay")

var scan_clock := 0.
func _process_scan_for_servers(delta: float) -> void:
	scan_clock -= delta

	if scan_clock <= 0.:
		scan_clock = 5.

		scan_client.set_broadcast_enabled(true)
		scan_client.set_dest_address("255.255.255.255", PORT + 1)
		scan_client.put_var(SCAN_MSG)
		Debug.log("scan_client broadcasting...")
	
	if scan_client.get_available_packet_count() > 0:
		scan_client.get_packet()
		var server_ip = scan_client.get_packet_ip()
		Debug.log("scan_client recieved something from %s!" % server_ip)
		found_server.emit(server_ip)

func _process(delta: float) -> void:
	if scan_server: _process_scan_server()
	if scan_for_servers: _process_scan_for_servers(delta)

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

	scan_server = UDPServer.new()
	scan_server.listen(PORT + 1)

	scan_for_servers = false

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	player_list.set(multiplayer.get_unique_id(),"Player")
	
	scan_for_servers = false
