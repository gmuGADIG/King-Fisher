extends Node

signal beat

@onready var timer : Timer = $Timer

@export var beats_per_minute : int = 140
@export var offset_ms : int = 0
var current_time : float = 0
var current_beat : int = 0
var beats_per_second : float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beats_per_second = beats_per_minute / 60.0
	get_tree().create_timer(offset_ms / 1000.0).timeout.connect(start_timer)

func start_timer() -> void:
	timer.start(1 / beats_per_second)
	timer.timeout.connect(on_beat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta

func on_beat():
	print("Beat %d" % current_beat)
	current_beat += 1
	beat.emit()
