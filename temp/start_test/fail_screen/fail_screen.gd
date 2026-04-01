extends Control

@onready var death_reason_label: Label = %DeathReasonLabel
@onready var time_label: Label = %TimeLabel

func string_of_msec(msec: float) -> String:
	var raw_seconds := int(msec / 1000)
	
	var seconds := raw_seconds % 60
	var minutes := (raw_seconds / 60) % 60
	var hours := raw_seconds / 3600
	
	var elements: Array[String] = []
	
	if hours != 0:
		elements.push_back(str(hours) + " hours")
	if minutes != 0:
		elements.push_back(str(minutes) + " minutes")
	if seconds != 0:
		elements.push_back(str(seconds) + " seconds")
	
	match len(elements):
		0:
			return "0 seconds"
		1:
			return elements[0]
		2:
			return elements[0] + " and " + elements[1]
		3:
			return "{0}, {1}, and {2}".format(elements)
		_:
			assert(false) # unreachable
			return ""

func _ready() -> void:
	death_reason_label.text = Plant.string_of_death_reason(World.death_reason)
	time_label.text = time_label.text \
		.format([string_of_msec(Time.get_ticks_msec() - World.level_started_msec)])

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://cpipujudik8wp")
