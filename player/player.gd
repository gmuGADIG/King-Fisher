class_name Player
extends CharacterBody3D

# Ragdoll
@export var ragdoll : PackedScene
@export var ragdolled := false

@export var speed := 10.
var held_item: Item

var last_pos : Vector3 = Vector3.ZERO


func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): 
		move_and_slide()
		return
	
	#Blocks input if player is ragdolled
	if is_ragdolled(): return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = Vector3(input.x,0,input.y) * speed
	
	sync_velocity.rpc(velocity)
	move_and_slide()

@rpc("reliable","authority","call_local")
func set_authority(id : int):
	set_multiplayer_authority(id)

func is_ragdolled() -> bool:
	return self.ragdolled

func set_ragdolled(val: bool) -> void:
	print("Updating ragdolled value of player ", self, " to ", val)
	self.ragdolled = val

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("scoreboard"):
		spawn_ragdoll.rpc(5, global_position)
		# print(is_ragdolled())
	if event.is_action_pressed("print_players"):
		Debug.print_players()
	if event.is_action_pressed("use_item"):
		#TODO: Don't let this happen if the player is aiming.
		use_held_item.rpc()

@rpc("unreliable_ordered")
func sync_velocity(vel: Vector3) -> void:
	velocity = vel

func pick_up_item(item: Item) -> void:
	# TODO: Parent it to the player's hand?
	# I imagine there might even be item-specific animations, but I think this should be extendable enough to accomodate that. Imagine an enum of item hold anim types and the item just reports which one it uses...
	
	# If you already have an item, don't pick up another one.
	if held_item!=null: return
	item.reparent(self, false)
	held_item = item
	held_item.is_held = true
	held_item.position = Vector3.ZERO

@rpc("call_local")
func use_held_item() -> void:
	# If you don't have an item, don't try and use a nonexistent item.
	if held_item==null:return
	held_item.use()
	held_item=null

@rpc("reliable", "call_local")
func spawn_ragdoll(duration: float,_position: Vector3) -> void:
	if is_ragdolled(): return
	# Prep for ragdoll
	set_ragdolled(true)

	# Creates Ragdoll
	Debug.log("Spawning agdoll at ", _position, "by player ", multiplayer.get_remote_sender_id(), " on client: ", multiplayer.get_unique_id())
	Debug.log("----------\n")
	var new_ragdoll: Ragdoll = ragdoll.instantiate()
	add_sibling(new_ragdoll)
	new_ragdoll.position = _position
	self.hide()

	# Timer before resetting
	await get_tree().create_timer(duration).timeout

	# Cleanup
	new_ragdoll.queue_free()
	self.show()
	set_ragdolled(false)
