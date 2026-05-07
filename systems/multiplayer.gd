extends Node

signal new_player(id: int)
signal found_server(ip: String, hostname: String, playerCount: String)
signal player_loaded(id: int)
signal start_game
signal server_disconnected

const PORT = 25575
const MAX_CLIENTS = 4
const SCAN_MSG = "iwannaplay"
const SCAN_INTERVAL := 5.

var allow_connections : bool = true
var player_list: Dictionary[int,ServerConnection] = {}
var loaded_players: Array[int]

var scan_server: UDPServer

var scan_for_servers := false
var scan_client: PacketPeerUDP

var displayName: String
#Allowed maps starts with a safety in case start game is loaded without going into lobby menu
var allowedMaps:Array = ["res://world/catwalk/catwalk.tscn","res://world/heightmap_test/heightmap_test.tscn","res://world/level-coffin/level-coffin.tscn","res://world/level-docks/level-docks.tscn","res://world/catwalk/catwalk.tscn"]

#var HUD = LobbyHUD.new();
var game_starting : bool = false

func _ready() -> void:
	# listen for when clients connect -- runs on both client and server
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
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
			var playersOnlineString: String = str(int(multiplayer.get_peers().size())+1) + "/" + str(MAX_CLIENTS)
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
	#if (game_in_progress == true):
		#disconnect_client.rpc_id(id,"match in progress")
		#return
	
	if not multiplayer.is_server():
		return
	if (player_list.size() >= MAX_CLIENTS):
		disconnect_client.rpc_id(id, "lobby full")
		player_list.erase(id)
		return
	
	Debug.log("peer ",id," connected")
	var server = ServerConnection.new()
	server.playerName = "Player"
	server.ready = false
	player_list.set(id,server)
	new_player.emit(id)

func _on_peer_disconnected(id : int) -> void:
	Debug.log("Player ", id, " left")
	if multiplayer.is_server() && id != 1:
			delete_disconnected_player.rpc(id)

func disconnect_from_game() -> void:
	Debug.log("Disconnecting")
	# If the host is disconnecting then let everyone else know
	if multiplayer.is_server():
		multiplayer.multiplayer_peer = null
		if scan_server: # only not true in editor F6 afaik
			scan_server.stop()
		player_list.clear()
		_on_server_disconnected()
	else:
		_disconnect_request.rpc_id(1)

@rpc("any_peer", "call_local")
func _disconnect_request() -> void:
	if not is_multiplayer_authority(): return
	if player_list.size() == 1:
		_on_peer_disconnected(1)
	else:
		multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_remote_sender_id())

@rpc("authority", "call_local")
func delete_disconnected_player(id) -> void:
	#Deletes the player's body
	if player_list.get(id).player:
		player_list.get(id).player.queue_free()

	#Cleanups the player's index
	player_list.erase(id)

@rpc("reliable")
func learn_player(player_id: int, player_name: String, player_path: NodePath) -> void:
	player_list.get_or_add(player_id)
	var server_conn = ServerConnection.new()
	server_conn.playerName = player_name
	server_conn.player = get_node(player_path)
	player_list.set(player_id, server_conn)

func broadcast_player_info() -> void:
	await get_tree().process_frame
	for player_id in player_list.keys():
		var server_conn = player_list.get(player_id)
		learn_player.rpc(player_id, server_conn.playerName, server_conn.player.get_path())

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
	##TODO: Pick Song
	##TODO: Select map
	
	##TODO: More stuff added to this to set up in WorldGameplay
	set_up_round_settings.rpc(
		LobbySettings.roundTime
	)
	await _countdown(5)
	if(!multiplayer.is_server()):
		return

	#var levelLoad:String = allowedMaps.pick_random()
	var levelLoad : String = "res://world/level-docks/level-docks.tscn"
	
	load_players.rpc(levelLoad)
	Debug.log(player_list.size())
	for i in range(player_list.size()):
		await player_loaded
	await get_tree().process_frame
	
	#TODO game goes

func set_up_round_settings(round_time : float) -> void:
	WorldGameplay.round_time = round_time
	
@rpc("authority","call_local","reliable")
func load_players(level: String):
	
	SceneTransition.change_to_file(level)
	
func _handle_ready_up() -> void:
	if get_tree().get_first_node_in_group("Lobby") == null:
		return
	
	if not multiplayer.is_server():
		set_ready.rpc_id(1)
			
	if not multiplayer.is_server(): return
	if game_starting: return
	
	for player in player_list:
			if not player_list.get(player).ready:
				return
	
	game_starting = true
	start_game.emit()
	start_the_game.rpc()
			
func set_map(mapString:String,pool:Array):
	#Array to be returned
	#Normalize the binary string, has to be the same length as pool
	for i in range(pool.size()- mapString.length()):
		mapString = "0" + mapString
		
	for i in range(mapString.length()):
		if mapString[i] == "0":
			pool.remove_at(i)
	allowedMaps = pool
			
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
	#multiplayer.connection_failed.connect(show_disconnected_message.bind("join error"))
	multiplayer.multiplayer_peer = peer
	var server = ServerConnection.new()
	server.playerName = "Player"
	server.ready = false
	player_list.set(multiplayer.get_unique_id(),server)
	scan_for_servers = false

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	player_list.clear()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")
	server_disconnected.emit()

@rpc("any_peer", "call_local")
func report_loaded() -> void:
	loaded_players.push_back(multiplayer.get_remote_sender_id())
	player_loaded.emit(multiplayer.get_remote_sender_id())

@rpc("call_local")
func results_screen(place: int) -> void:
	Debug.log("results_screen(place = %d)" % place)
	ResultsScreen.place = place
	SceneTransition.change_to_file("res://ui/results/results_screen.tscn")

# host disconnecting client
@rpc("reliable","call_local","authority")
func disconnect_client(msg : String) -> void:
	#show_disconnected_message.rpc_id(id, msg)
	#await get_tree().create_timer(1).timeout # this timer gives the rpc time to send out
	# multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
	#player_list.erase(id)
	#if my_id == id:
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")
	return
