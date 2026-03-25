extends Node

signal new_player(id: int)
signal found_server(ip: String, hostname: String, playerCount: String)

const PORT = 25575
const MAX_CLIENTS = 4
const SCAN_MSG = "iwannaplay"
const SCAN_INTERVAL := 5.

var allow_connections : bool = true
var player_list: Dictionary[int,String] = {}
var game_in_progress: bool = false

var scan_server: UDPServer


var scan_for_servers := true
var scan_client: PacketPeerUDP

var displayName: String


func _ready() -> void:
	# listen for when clients connect -- runs on both client and server
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
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
	player_list.set(id,"Player")
	new_player.emit(id)
	# tell the new player about all the other players connected to the server.
	learn_players.rpc_id(id, player_list)

func _on_peer_disconnected(id : int) -> void:
	Debug.log(id, " left")
	
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
	#multiplayer.connection_failed.connect(show_disconnected_message.bind("join error"))
	#multiplayer.server_disconnected.connect(show_disconnected_message)
	multiplayer.multiplayer_peer = peer
	player_list.set(multiplayer.get_unique_id(),"Player")
	scan_for_servers = false

# host disconnecting client
@rpc("reliable","call_local","any_peer")
func disconnect_client(msg : String) -> void:
	Debug.log(multiplayer.get_unique_id(), " disconnected")
	#show_disconnected_message.rpc_id(id, msg)
	#await get_tree().create_timer(1).timeout # this timer gives the rpc time to send out
	multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
	#player_list.erase(id)
	#if my_id == id:
		
	get_tree().change_scene_to_file("res://ui/lobby_browser/lobby_browser.tscn")
	return
#
## client displaying error message when disconnected
#@rpc("reliable")
#func show_disconnected_message(msg : String) -> void:
	#match msg:
		#"lobby full":
			#Debug.log("Client disconnected due to join attempt on full lobby!") # This error goes unused, as the client is not connected to the game in the first place.
			##TODO: Make a seperate way to detect full lobbies (waiting for "Add name and player count to server browser" git issue to be merged to main)
			#get_tree().change_scene_to_file("res://ui/lobby_browser/lobby_full_message.tscn")
		#"match in progress": 
			#Debug.log("Client disconnected due to join attempt during in-progress match!")
			#get_tree().change_scene_to_file("res://ui/lobby_browser/lobby_full_message.tscn") #TODO: Change this to a "lobby full" screen
		#"join error":
			#Debug.log("Client failed to join!")
			#get_tree().change_scene_to_file("res://ui/lobby_browser/lobby_full_message.tscn") #TODO: Change this to a "join error" screen
		#_:
			#Debug.log("Client disconnected due to undisclosed reason!")
			#get_tree().change_scene_to_file("res://ui/lobby_browser/lobby_full_message.tscn") #TODO: Change this to an "unknown error" screen
