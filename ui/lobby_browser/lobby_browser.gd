extends Control

# Todo: Implement a function that utilizes this
signal closed

@export var server_info_packed : PackedScene

@onready var lobby_creation_window : TextureRect = $LobbyCreationWindow
@onready var name_text := $DisplayName/NameInput
var seen_ips: Dictionary[String, bool]
var infos: Dictionary[String, ServerInfo]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Multiplayer.found_server.connect(_on_found_server)
	lobby_creation_window.hide()

func _on_host_button_pressed() -> void:
	lobby_creation_window.show()

func _on_create_back_button_pressed() -> void:
	lobby_creation_window.hide()


func _on_create_lobby_button_pressed() -> void:
	#if name_text.text.length() == 0:
		#name_text.text = "Player"+str(randi_range(1,999))
	Multiplayer.playerDisplayName = %NameInput.text
	Multiplayer.create_server(%LobbyNameInput.text)
	
	Debug.log("Host Created")
	#Multiplayer.announce_name.rpc_id(1,%NameInput.text)
	get_tree().change_scene_to_file("res://world/lobby/lobby.tscn")


func _on_found_server(ip: String, hostname: String, playerCount: String, status: String) -> void:
	if ip in seen_ips: 
		infos[ip].status = status
		return
	seen_ips[ip] = true

	var server_info: ServerInfo = server_info_packed.instantiate()

	# hacky way to create an alternating bg color effect for the list
	# there's probably an intended way of doing this, but ¯\_(ツ)_/¯
	if %ServerInfoParent.get_child_count() % 2 == 0:
		server_info.self_modulate.a = 1.5 # yes this works, it makes it darker
	
	server_info.hostname = hostname
	server_info.status = status
	server_info.playerCount = playerCount
	server_info.ip = ip
	
	server_info.pressed.connect(func() -> void:
		Multiplayer.playerDisplayName = %NameInput.text
		Multiplayer.join_server(ip)
		Debug.log("Lobby Joined")
		get_tree().change_scene_to_file("res://world/lobby/lobby.tscn")
	)
	infos[ip] = server_info
	%ServerInfoParent.add_child(server_info)


func _on_refresh_button_pressed() -> void:
	Multiplayer.scan_clock = 0

func _on_back_button_pressed() -> void:
	closed.emit()

func _on_player_count_button_pressed(count: int):
	Multiplayer.size_limit = count
