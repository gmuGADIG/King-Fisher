extends Control

@onready var name_text := $DisplayName/NameInput
var seen_ips: Dictionary[String, bool]

func _ready() -> void:
	Multiplayer.found_server.connect(_on_found_server)


func _on_host_button_pressed() -> void:
	#if name_text.text.length() == 0:
		#name_text.text = "Player"+str(randi_range(1,999))
	Multiplayer.create_server()
	Debug.log("Host Created")
	get_tree().change_scene_to_file("res://world/lobby/lobby.tscn")


func _on_found_server(ip: String) -> void:
	if ip in seen_ips: return
	seen_ips[ip] = true

	var server_info: ServerInfo = load("res://ui/main_menu/server_info.tscn").instantiate()

	# hacky way to create an alternating bg color effect for the list
	# there's probably an intended way of doing this, but ¯\_(ツ)_/¯
	if %ServerInfoParent.get_child_count() % 2 == 0:
		server_info.self_modulate.a = 1.5 # yes this works, it makes it darker

	server_info.ip = ip
	server_info.pressed.connect(func() -> void:
		Multiplayer.join_server(ip)
		Debug.log("Lobby Joined")
		get_tree().change_scene_to_file("res://world/lobby/lobby.tscn")
	)

	%ServerInfoParent.add_child(server_info)
