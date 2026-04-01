class_name Insect
extends Area2D

signal killed

@export var speed := 200

@onready var death_sound: PersistantAudioStreamPlayer = %DeathSound

func _ready() -> void:
	if Plant.instance == null:
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	look_at(Plant.instance.global_position)

func _physics_process(delta: float) -> void:
	var to_plant := (Plant.instance.global_position - global_position) \
		.normalized()
		
	position += to_plant * speed * delta

func kill() -> void:
	death_sound.play_persistant()
	
	killed.emit()
	queue_free()
