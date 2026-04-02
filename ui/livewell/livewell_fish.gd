extends Control

var fish_file_name: String

func set_fish(fish_path: String, fish_type: String) -> void:
	fish_file_name = "res://fish/" + fish_type + "/" + fish_path + ".tres"