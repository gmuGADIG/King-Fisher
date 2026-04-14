extends Control

signal closed

const SAVE_PATH = "user://fishdex.json"

var loaded : bool = false
var fishdex_entries : Dictionary = {}

func _ready() -> void:
	hide()

	load_file()
	loaded = true

func load_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			fishdex_entries = json.get_data()
	else:
		save_file()

func caught_fish(new_fish : Fish) -> void:
	if fishdex_entries.has(new_fish.name):
		fishdex_entries[new_fish.name] += 1
	else:
		fishdex_entries[new_fish.name] = 1
	save_file()

func save_file() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(fishdex_entries))

func _on_back_button_pressed() -> void:
	closed.emit()
	Debug.log("Exiting FishDex")
	hide()
