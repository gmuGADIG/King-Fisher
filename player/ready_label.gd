extends Label3D

var do_update : bool = true

func _ready() -> void:
	if get_tree().current_scene.name == "Lobby":
		do_update = true
		show()
	else:
		do_update = false
		hide()

func _physics_process(delta: float) -> void:
	if not do_update:
		return
	
	var id : int = get_multiplayer_authority()
	if not Multiplayer.player_list.has(id):
		return
	
	var ready : bool = Multiplayer.player_list[id].ready
	
	if id == 1:
		text = "Host"
	elif ready:
		text = "Ready"
	else:
		text = "Not Ready"
