extends Node3D

var posY : float
var rotX : float
var rotZ : float

var clock: float = 0

func _ready() -> void:
	posY = position.y
	rotX = rotation.x
	rotZ = rotation.z
	if multiplayer.is_server():
		Multiplayer.new_player.connect(_on_player_join)

func _process(delta: float) -> void:
	clock += delta
	rotation.x = remap(sin(clock/1.33), rotX-1, rotX+1, -.01, .01)
	rotation.z = remap(sin(clock/1.7), rotZ-1, rotZ+1, -.025, .025)
	position.y = remap(sin(clock/1.5), posY-1, posY+1, 0.15, 1.5)

func _on_player_join(id : int) -> void:
	if not multiplayer.is_server():
		return
	
	_sync_boat.rpc_id(id,clock)

@rpc("reliable","authority","call_remote")
func _sync_boat(clock : float) -> void:
	self.clock = clock
