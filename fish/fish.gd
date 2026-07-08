extends Resource
class_name Fish

enum Grade{
	UNSET,
	LEFTOVERS,
	FRESH,
	PREMIUM,
	SUSHI,
}

static var leftover_particle : BoxMesh = load("res://fish/particles/leftovers_particle.tres")
static var fresh_particle : BoxMesh = load("res://fish/particles/fresh_particle.tres")
static var premium_particle : BoxMesh = load("res://fish/particles/premium_particle.tres")
#static var sushi_particle : BoxMesh = load("res://fish/particles/sushi_particle.tres")

static var sushi_materials : Array[StandardMaterial3D] = [
	load("res://fish/particles/sushi/sushi_mat_red.tres"),
	load("res://fish/particles/sushi/sushi_mat_orange.tres"),
	load("res://fish/particles/sushi/sushi_mat_yellow.tres"),
	load("res://fish/particles/sushi/sushi_mat_green.tres"),
	load("res://fish/particles/sushi/sushi_mat_blue.tres"),
	load("res://fish/particles/sushi/sushi_mat_purple.tres"),
	load("res://fish/particles/sushi/sushi_mat_pink.tres"),
]

static var leftover_fishes : Array[Fish] = [
	load("res://fish/leftovers/british_fish.tres"),
	load("res://fish/leftovers/patchwork_fish.tres"),
	load("res://fish/leftovers/performative_fish.tres"),
	load("res://fish/leftovers/phishing_scam_fish.tres"),
	load("res://fish/leftovers/sardines.tres"),
	load("res://fish/leftovers/steven.tres"),
	load("res://fish/leftovers/taiyaki_fish.tres"),
	load("res://fish/leftovers/trash_fish.tres")
]
static var fresh_fishes : Array[Fish] = [
	load("res://fish/fresh/angle_r_fish.tres"),
	load("res://fish/fresh/bassilisk.tres"),
	load("res://fish/fresh/emo_bass_fish.tres"),
	load("res://fish/fresh/lovers_fish.tres"),
	load("res://fish/fresh/movie_snob_fish.tres"),
	load("res://fish/fresh/please_I_need_fish.tres"),
	load("res://fish/fresh/your_name_fish.tres"),
	load("res://fish/fresh/yuri_fish.tres")
]
static var premium_fishes : Array[Fish] = [
	load("res://fish/premium/ceo_fish.tres"),
	load("res://fish/premium/gold_fish.tres"),
	load("res://fish/premium/man_o_war_fish.tres"),
	load("res://fish/premium/sasha_splash.tres"),
	load("res://fish/premium/shrimp_tempura_fish.tres"),
	load("res://fish/premium/star_fish.tres"),
	load("res://fish/premium/thrasher_shark.tres")
]
static var sushi_fishes : Array[Fish] = [
	load("res://fish/sushi/angel_devil_fish.tres"),
	load("res://fish/sushi/fish_seven.tres"),
	load("res://fish/sushi/fish_with_legs.tres"),
	load("res://fish/sushi/moai_fish.tres"),
	load("res://fish/sushi/oh_my_cod.tres"),
	load("res://fish/sushi/sword_fish.tres"),
	load("res://fish/sushi/the_quote_on_quote_fish.tres")
]

@export var fish_name : String
@export var grade : Grade
@export var sprite : Texture
@export var catch_blurb : String
@export_multiline var description : String


func _init() -> void:
	return

static func _static_init() -> void:
	var yn_fish: Fish = load("res://fish/fresh/your_name_fish.tres")

	# don't do this easter egg if the catch blurb is actually set
	if not yn_fish.catch_blurb.is_empty():
		return

	# get the player's user name from their computer
	var player_name := ""
	if OS.has_environment("USERNAME"): # winblows
		player_name = OS.get_environment("USERNAME")
	elif OS.has_environment("USER"): # younex
		player_name = OS.get_environment("USER")

	yn_fish.catch_blurb = "It's name is %s." % player_name

func get_grade_string() -> String:
	match grade:
		Grade.LEFTOVERS:
			return "Leftovers"
		Grade.FRESH:
			return "Fresh"
		Grade.PREMIUM:
			return "Premium"
		Grade.SUSHI:
			return "Sushi"
		_:
			return "Unset"

static func pick(fish_grade : Fish.Grade) -> int:
	match fish_grade:
		Fish.Grade.LEFTOVERS:
			return randi_range(0,leftover_fishes.size()-1)
		Fish.Grade.FRESH:
			return randi_range(0,fresh_fishes.size()-1)
		Fish.Grade.PREMIUM:
			return randi_range(0,premium_fishes.size()-1)
		Fish.Grade.SUSHI:
			return randi_range(0,sushi_fishes.size()-1)
		_:
			assert(false, "invalid grade")
			return -1

static func create(fish_grade : Grade, index : int) -> Fish:
	match fish_grade:
		Fish.Grade.LEFTOVERS:
			return leftover_fishes[index]
		Fish.Grade.FRESH:
			return fresh_fishes[index]
		Fish.Grade.PREMIUM:
			return premium_fishes[index]
		Fish.Grade.SUSHI:
			return sushi_fishes[index]
		_:
			assert(false, "invalid grade")
			return null

func get_score() -> int:
	match grade:
		Grade.LEFTOVERS:
			return 100
		Grade.FRESH:
			return 200
		Grade.PREMIUM:
			return 300
		Grade.SUSHI:
			return 500
		_: # This is also known as Unset Grade
			return 0

static func custom_sort_fish(a : Fish, b : Fish) -> bool:
	##Grade
	if a.grade > b.grade:
		return true
	elif b.grade > a.grade:
		return false
	
	##Name
	return a.fish_name < b.fish_name

func serialize() -> Array:
	var array : Array[Fish]
	match grade:
		Fish.Grade.LEFTOVERS:
			array = leftover_fishes
		Fish.Grade.FRESH:
			array = fresh_fishes
		Fish.Grade.PREMIUM:
			array = premium_fishes
		Fish.Grade.SUSHI:
			array = sushi_fishes
		_:
			assert(false, "invalid grade")
			array = []
	
	assert(array.has(self), "Illegal fish")
	return [grade,array.find(self)]

func grade_color() -> Color:
	match grade:
		Fish.Grade.LEFTOVERS:
			return Color.WHITE # Gray
		Fish.Grade.FRESH:
			return Color.GREEN # Green
		Fish.Grade.PREMIUM:
			return Color.PURPLE # Purple
		Fish.Grade.SUSHI:
			return Color.GOLD # Gold
		_:
			return Color.DIM_GRAY # Gray for Unset or unknown grades

func grade_particle() -> Mesh:
	match grade:
		Fish.Grade.LEFTOVERS:
			return leftover_particle
		Fish.Grade.FRESH:
			return fresh_particle
		Fish.Grade.PREMIUM:
			return premium_particle
		Fish.Grade.SUSHI:
			#var sushi_particle : BoxMesh = BoxMesh.new()
			#sushi_particle.size = Vector3(0.05,0.05,0.05)
			#sushi_particle.albedo_color = sushi_materials.pick_random()
			return premium_particle
		_:
			return null

func grade_string() -> String:
	match grade:
		Grade.UNSET:
			return "Unset"
		Grade.LEFTOVERS:
			return "Leftovers"
		Grade.FRESH:
			return "Fresh"
		Grade.PREMIUM:
			return "Premium"
		Grade.SUSHI:
			return "Sushi"
		_:
			return "ERROR"
