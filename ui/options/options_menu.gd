extends Control
class_name Options

static var mouse_sensitivity : float = 1
static var aim_sesntivity : float = 1
static var master_volume : float = 1:
	set(val):
		master_volume = val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), val)
static var sfx_volume : float = 1:
	set(val):
		sfx_volume = val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), val)
static var music_volume : float = 1:
	set(val):
		music_volume = val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), val)

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$OptionsPanel/VBoxContainer/MouseSensitivtySlider.value = mouse_sensitivity
	$OptionsPanel/VBoxContainer/AimingSensitivitySlider.value = aim_sesntivity
	$OptionsPanel/VBoxContainer/MasterSlider.value = master_volume
	$OptionsPanel/VBoxContainer/SFXSlider.value = sfx_volume
	$OptionsPanel/VBoxContainer/MusicSlider.value = music_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		print("Options Menu!")
		visible = not visible

func _on_master_slider_value_changed(value: float) -> void:
	master_volume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_volume = value
	
	
func _on_music_slider_value_changed(value: float) -> void:
	music_volume = value

func _on_mouse_sensitivty_slider_value_changed(value: float) -> void:
	mouse_sensitivity = value

func _on_aim_sensitivty_slider_value_changed(value: float) -> void:
	aim_sesntivity = value

func _on_keybinds_button_pressed() -> void:
	var keybinds_menu_scene = preload("res://ui/keybinds/keybind_menu.tscn")
	var keybinds_menu = keybinds_menu_scene.instantiate()
	add_sibling(keybinds_menu)
	queue_free()

func _on_exit_button_pressed() -> void:
	closed.emit()
	print("Options Menu!")
	hide()
