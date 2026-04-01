extends Node

var michaels: Array[String] = [
	"michael",
	"micheal",
	"mikel",
	"michl",
	"mitchl",
	"mikeal",
	"mikale",
	"mikael",
	"miceal",
	"miguel",
	"mikuel",
	"morical",
	"mario",
	"marchicle",
	"marco",
	"michæl",
	"mychel",
	"mycoal",
	"mychime",
	"miracle",
	"micolla",
	"mycrew",
	"mike",
	"micycle",
	"marchell",
	"marchle",
	"michal",
	"mikal"
]

func _ready() -> void:
	var window := get_window()
	while true:
		window.title = michaels.pick_random() + "s mansion"
		await get_tree().create_timer(1).timeout
