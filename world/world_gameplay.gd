class_name WorldGameplay
extends WorldBase

const FISH_SPAWN_RATE : float = 5.0

static var round_time : float
#static var item_pool :
#static var item_spawnrate : float

##The areas that define the different pool regions
@export var fish_spawners : Array[FishSpawner]
##How likely this pool will be picked when randomly selecting a pool. Must be the same size as the water_pools list
@export var fish_spawner_weights : Array[int]

#var water_pool_weight_total : int = 0

var hud : GameHud
## Amount of time before the game ends
var remaining_time : float = LobbySettings.roundTime
var fish_rng : RandomNumberGenerator


func _ready() -> void:
	assert(fish_spawner_weights.size() == fish_spawners.size(), "water pool count and weight counts are not equal")
	hud = %GameHud
	super._ready()
	hud.show()
	remaining_time = round_time
	
	#for weight in water_pool_weights:
		#water_pool_weight_total += weight
	
	if multiplayer.is_server():
		fish_rng = RandomNumberGenerator.new()
		
		var fish_timer : Timer = Timer.new()
		fish_timer.timeout.connect(_spawn_fish)
		fish_timer.one_shot = false
		fish_timer.wait_time = FISH_SPAWN_RATE ##This might need to be different per map?
		add_child(fish_timer)
		fish_timer.start()
	

func _process(delta: float) -> void:
	##Unused for now
	#super._process(delta)
	remaining_time -= delta
	hud.update_time(remaining_time)

func _spawn_fish() -> void:
	if not multiplayer.is_server():
		return
	
	##Choose pool
	var index : int = fish_rng.rand_weighted(fish_spawner_weights)
	#var rand : int = randi_range(1,water_pool_weight_total)
	#var target_pool : WaterPool = null
	#
	#for i in range(water_pool_weights.size()):
		#var curr_weight : int = water_pool_weights[i]
		#if rand <= curr_weight:
			##Found Pol
			#target_pool = water_pools[i]
		## Try the next pool
		#rand -= curr_weight
	assert(index != -1, "weights empty")
	var target_spawner = fish_spawners[index]
	assert(target_spawner != null, "No pool selected?")
	
	##Pick random point in pool
	#var test : Sprite3D = Sprite3D.new()
	#test.texture = load("res://temp/temp_art/icon.svg")
	#test.scale = Vector3(0.25,0.25,0.25)
	#add_child(test)
	#test.global_position = target_spawner.get_random_point()
	#print(target_spawner.get_random_point())
	
	##Pick Specific fish
	var grade : Fish.Grade = target_spawner.fish_spawnrate.pick_rarity()
	##TODO: Spawn fish on all clients
	
	##NOTE: To make sure fish are synced across clients (specifically when someone fishes one up)
	##The server might want to be the one managing when fish are fished up?
	#create_fish.rpc()
	pass


##Create the fish on all clients
@rpc("authority","reliable","call_local")
func create_fish(pos : Vector3, fish : Fish) -> void:
	pass
