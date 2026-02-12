class_name Player
extends CharacterBody3D

signal client_space(id: int)

@export var speed := 10.
@export var clientready := false

var last_pos : Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector3(input.x,0,input.y) * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("print_players"):
		Debug.print_players()
	if event.is_action_pressed("jump") and not is_multiplayer_authority():
		print("I space and client")
		clientready = not clientready
		client_space.emit(0, clientready)
	if event.is_action_pressed("jump") and is_multiplayer_authority():
		print("I space and host")
		var list = get_tree().root.get_child(0).player_list
		
		#if(all clients ready (n - 1 players, where n is players in lobby):
		#	print("Everyone is ready, starting...")
		#else:
		#	print("not everyone is ready, wait")
		

@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel
	
