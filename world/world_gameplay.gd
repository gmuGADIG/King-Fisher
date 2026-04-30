class_name WorldGameplay
extends WorldBase

const FISH_SPAWN_RATE : float = 5.0

static var round_time : float
#static var item_pool :
#static var item_spawnrate : float

##The areas that define the different pool regions
@export var water_pools : Array[CSGPolygon3D]
##How likely this pool will be picked when randomly selecting a pool. Must be the same size as the water_pools list
@export var water_pool_weights : Array[int]

var water_pool_weight_total : int = 0

var hud : GameHud
## Amount of time before the game ends
var remaining_time : float = LobbySettings.roundTime

func _ready() -> void:
	assert(water_pool_weights.size() == water_pools.size(), "water pool count and weight counts are not equal")
	hud = %GameHud
	super._ready()
	hud.show()
	remaining_time = round_time
	
	for weight in water_pool_weights:
		water_pool_weight_total += weight
	
	if multiplayer.is_server():
		var fish_timer : Timer = Timer.new()
		fish_timer.timeout.connect(_spawn_fish)
		fish_timer.one_shot = false
		fish_timer.wait_time = FISH_SPAWN_RATE ##This might need to be different per map?
		add_child(fish_timer)
	

func _process(delta: float) -> void:
	##Unused for now
	#super._process(delta)
	remaining_time -= delta
	hud.update_time(remaining_time)

func _spawn_fish() -> void:
	if not multiplayer.is_server():
		return
	
	##Choose pool
	var rand : int = randi_range(1,water_pool_weight_total)
	var target_pool : CSGPolygon3D = null
	
	for i in range(water_pool_weights.size()):
		var curr_weight : int = water_pool_weights[i]
		if rand <= curr_weight:
			#Found Pol
			target_pool = water_pools[i]
		# Try the next pool
		rand -= curr_weight
	
	assert(target_pool != null, "No pool selected?")
	
	##TODO: Pick random point in pool
	
	
	##TODO: Pick Specific fish
	##TODO: Spawn fish on all clients
	
	##NOTE: To make sure fish are synced across clients (specifically when someone fishes one up)
	##The server might want to be the one managing when fish are fished up?
	#create_fish.rpc()
	pass

@rpc("authority","reliable","call_local")
func create_fish(pos : Vector3, fish : Fish) -> void:
	pass
