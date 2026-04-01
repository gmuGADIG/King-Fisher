extends Node

signal new_player(id: int)
signal found_server(ip: String, hostname: String, playerCount: String)
signal player_loaded(id: int)
signal start_game

const PORT = 25575
const MAX_CLIENTS = 3
const SCAN_MSG = "iwannaplay"
const SCAN_INTERVAL := 5.

var allow_connections : bool = true
var player_list: Dictionary[int,ServerConnection] = {}
var loaded_players: Array[int]

var scan_server: UDPServer

var scan_for_servers := false
var scan_client: PacketPeerUDP

var displayName: String
#var HUD = LobbyHUD.new();


func _ready() -> void:
	# listen for when clients connect -- runs on both client and server
	multiplayer.peer_connected.connect(_on_peer_connected)
	scan_client = PacketPeerUDP.new() # listener for scan packets on LAN scanning screen

# listen for clients looking for servers
func _process_scan_server() -> void:
	scan_server.poll()
	if scan_server.is_connection_available():
		Debug.log("heard a scan packet")
		var peer := scan_server.take_connection()
		# tell them we're a server
		if peer.get_var(0) == SCAN_MSG:
			Debug.log("sending something to the client.")
			# TODO: send meaningful data, like our username or something
			var playersOnlineString: String = str(int(multiplayer.get_peers().size())+1) + "/" + str(MAX_CLIENTS+1)
			peer.put_var([displayName, playersOnlineString])
			
# measure the time since we shouted into the void
var scan_clock := 0.
func _process_scan_for_servers(delta: float) -> void:
	scan_clock -= delta

	if scan_clock <= 0.:
		# shout into the void every SCAN_INTERVAL seconds
		scan_clock = SCAN_INTERVAL

		scan_client.set_broadcast_enabled(true) # we're gonna use the "broadcast address" to shout into the void

		# tell everybody on this LAN we're looking for a server
		scan_client.set_dest_address("255.255.255.255", PORT + 1)
		scan_client.put_var(SCAN_MSG)

		# also shout at ourselves in case there's multiple instances of the game running
		scan_client.set_dest_address("127.0.0.1", PORT + 1)
		scan_client.put_var(SCAN_MSG)

		Debug.log("scan_client broadcasting...")
	
	# also make sure to listen for responses to our shouts
	while scan_client.get_available_packet_count() > 0:
		var s = scan_client.get_var()
		var server_ip = scan_client.get_packet_ip()
		var foundHostName: String = s[0]
		var playersOnlineString: String = s[1]
		Debug.log("scan_client recieved something from %s!" % server_ip)

		
		found_server.emit(server_ip, foundHostName, playersOnlineString)

func _process(delta: float) -> void:
	if scan_server: _process_scan_server()
	if scan_for_servers: _process_scan_for_servers(delta)

# when a player connects to the server,
func _on_peer_connected(id: int) -> void:
	Debug.log("on peer connect")
	if not multiplayer.is_server():
		return
	
	Debug.log("peer ",id," connected")
	var server = ServerConnection.new()
	server.playerName = "Player"
	server.ready = false
	player_list.set(id,server)
	new_player.emit(id)
	# tell the new player about all the other players connected to the server.
	learn_players.rpc_id(id, player_list.keys())

@rpc("reliable")
func learn_players(new_player_ids: Array[int]) -> void:
	for player in new_player_ids:
		if not player in player_list:
			var server = ServerConnection.new()
			server.playerName = "Player"
			server.ready = false
			player_list.set(player,server)
			new_player.emit(player)

func _countdown(duration: int) -> void:
	var label: CountdownLabel = load("res://ui/HUD/countdown_label.tscn").instantiate()
	label.duration = duration
	label.position = Vector2(500, 500)
	get_tree().current_scene.add_child(label)
	label.start()
	await label.finished
	label.queue_free()

@rpc("call_local")
func start_the_game():
	await _countdown(5)
	load_players()
	Debug.log(player_list.size())
	for i in range(player_list.size()):
		await player_loaded
	await get_tree().process_frame
	await _countdown(5)
	#TODO game goes
	

	
func load_players():
	ScreenTransition.change_to_file("res://world/heightmap_test/heightmap_test.tscn")
	
func _handle_ready_up() -> void:
	if get_tree().get_first_node_in_group("Lobby") == null:
		return
	
	if not multiplayer.is_server():
		set_ready.rpc_id(1);
			
	if multiplayer.is_server():
		for player in player_list:
				if not player_list.get(player).ready:
					return
		start_game.emit()
		start_the_game.rpc()
			

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ready_up"):
		_handle_ready_up()

@rpc("any_peer","call_local","reliable")
func set_ready():
	var sender = multiplayer.get_remote_sender_id();
	player_list[sender].ready = !player_list[sender].ready;
	
func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	var server = ServerConnection.new()
	server.playerName = "Player"
	server.ready = true
	player_list.set(1, server)

	scan_server = UDPServer.new()
	scan_server.listen(PORT + 1)

	scan_for_servers = false

func join_server(ip : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	var server = ServerConnection.new()
	server.playerName = "Player"
	server.ready = false
	player_list.set(multiplayer.get_unique_id(),server)
	scan_for_servers = false

@rpc("any_peer", "call_local")
func report_loaded() -> void:
	loaded_players.push_back(multiplayer.get_remote_sender_id())
	player_loaded.emit(multiplayer.get_remote_sender_id())
