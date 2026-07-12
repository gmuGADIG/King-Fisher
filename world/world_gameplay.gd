class_name WorldGameplay
extends WorldBase

static var fish_shadows : Dictionary[int,FishShadow]
static var next_fish_shadow_id : int = 0

static var fish_shadow : PackedScene = load("res://world/fish_spawner/fish_shadow.tscn")
const FISH_SPAWN_RATE : float = 5.0

static var song : Song
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
@onready var remaining_time : float = LobbySettings.roundTime
var fish_rng : RandomNumberGenerator


func _ready() -> void:
	MainMusicPlayer.play_song(song)
	assert(fish_spawner_weights.size() == fish_spawners.size(), "water pool count and weight counts are not equal")
	hud = %GameHud
	super._ready()
	hud.show()
	if (round_time != 0.):
		remaining_time = round_time
	else:
		Debug.log_err("round_time == 0.")
	
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
	

var almost_over_not_triggered := true
var round_going = true
func _process(delta: float) -> void:
	##Unused for now
	#super._process(delta)
	remaining_time -= delta
	hud.update_time(remaining_time)
	hud.get_node("%ActiveBuffs").update_buffs(delta)

	if remaining_time < 60. and almost_over_not_triggered:
		almost_over_not_triggered = false
		MainMusicPlayer.play_song(load("res://sound/music/song_files/mainleveldnb_jan.tres"))
		%AlarmSound.play()
	
	if Input.is_action_just_pressed("timer_to_one_min") and OS.has_feature("editor"):
		remaining_time = 61.

	if Input.is_action_just_pressed("timer_to_done") and OS.has_feature("editor"):
		remaining_time = 2.
	
	if remaining_time < 0. and round_going and multiplayer.is_server():
		round_going = false
		
		
		var players : Array[Player]
		for p in get_tree().get_nodes_in_group("Player"):
			players.append(p)
		players.sort_custom(sort_by_score)
		
		var ids : Array[int]
		for i in players.size():
			var id := players[i].get_multiplayer_authority()
			ids.append(id)
		
		while ids.size() < 4:
			ids.append(-1)
		
		Multiplayer.results_screen.rpc(ids[0],ids[1],ids[2],ids[3])

func sort_by_score(a : Player, b : Player) -> bool:
	return a.score > b.score

func _spawn_fish() -> void:
	if not multiplayer.is_server():
		return
	if fish_spawners.is_empty():
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
	var grade : Fish.Grade = target_spawner.pick_rarity()
	##TODO: Spawn fish on all clients
	var spawn_loc : Vector3 = target_spawner.get_random_point()
	
	var id : int = next_fish_shadow_id
	next_fish_shadow_id += 1
	create_fish.rpc(id,spawn_loc,grade,Fish.pick(grade))
	
	
	##NOTE: To make sure fish are synced across clients (specifically when someone fishes one up)
	##The server might want to be the one managing when fish are fished up?
	#create_fish.rpc()
	pass


##Create the fish on all clients
@rpc("authority","reliable","call_local")
func create_fish(id : int, pos : Vector3, grade : Fish.Grade, grade_index : int) -> void:
	var fish : Fish = Fish.create(grade,grade_index)
	assert(fish != null, "illegal")
	#Debug.log("Spawning Fish");
	var new_fish_shadow : FishShadow = fish_shadow.instantiate()
	new_fish_shadow.name = "FishShadow"+str(id)
	##HACK: THIS IS FOR SHOWOFF NIGHT. Fish sometimes is just null for some reason
	#if fish == null:
		#fish = load("res://fish/leftovers/british_fish.tres")
	assert(fish != null, "illegal")
	
	new_fish_shadow.fish = fish
	new_fish_shadow.id = id
	add_child(new_fish_shadow)
	new_fish_shadow.global_position = pos
	fish_shadows.set(id,new_fish_shadow)
