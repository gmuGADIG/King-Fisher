class_name Plant
extends Area2D

enum DeathReason {
	NoWater, NoHealth
}

static func string_of_death_reason(reason: DeathReason) -> String:
	match (reason):
		DeathReason.NoWater:
			return "Your plant died to a lack of water!"
		DeathReason.NoHealth:
			return "Your plant died to insects eating it!"
		_:
			assert(false, "Unreachable!")
			return ""

signal health_changed(new_health: int)
signal water_changed(new_water: float)
signal died(reason: DeathReason)

static var instance: Plant

@export var water_drain_per_second := 5.0

var water := 100.0:
	set(v):
		water = min(v, max_water)
		water_changed.emit(water)
		water_bar.value = water
		
		if water <= 0:
			died.emit(DeathReason.NoWater)
	
@export var health := 4:
	set(v):
		health = min(v, max_health)
		health_changed.emit(health)
		health_bar.value = health
		
		if health <= 0:
			died.emit(DeathReason.NoHealth)

@onready var water_bar: ProgressBar = %WaterBar
@onready var health_bar: ProgressBar = %HealthBar

@onready var max_water := water
@onready var max_health := health

func _init() -> void:
	instance = self

func _ready() -> void:
	water_bar.min_value = 0
	water_bar.max_value = max_water
	water_bar.value = water
	
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = health

func _process(delta: float) -> void:
	water -= water_drain_per_second * delta

func _on_area_entered(area: Area2D) -> void:
	if area is Insect:
		health -= 1
		area.queue_free()

func _on_water_collector_area_entered(area: Area2D) -> void:
	if area is WaterDrop:
		if not area.vulnrable:
			await area.became_vulnrable
		area.queue_free()
		water += area.amount
