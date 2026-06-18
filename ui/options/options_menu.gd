extends Control
class_name Options

static var mouse_sensitivity : float = 1
static var aim_senstivity : float = 1
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
@onready var mouse_sens_slider = $OptionsPanel/VBoxContainer/MouseSensitivtySlider
@onready var aim_sens_slider = $OptionsPanel/VBoxContainer/AimingSensitivitySlider
@onready var sfx_slider = $OptionsPanel/VBoxContainer/SFXSlider
@onready var music_slider = $OptionsPanel/VBoxContainer/MusicSlider
@onready var master_slider = $OptionsPanel/VBoxContainer/MasterSlider

signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_sens_slider.value = mouse_sensitivity
	aim_sens_slider.value = aim_senstivity
	sfx_slider.value = sfx_volume
	music_slider.value = music_volume
	master_slider.value = master_volume
	hide()
	$OptionsPanel/VBoxContainer/MouseSensitivtySlider.value = mouse_sensitivity
	$OptionsPanel/VBoxContainer/AimingSensitivitySlider.value = aim_sesntivity
	$OptionsPanel/VBoxContainer/MasterSlider.value = master_volume
	$OptionsPanel/VBoxContainer/SFXSlider.value = sfx_volume
	$OptionsPanel/VBoxContainer/MusicSlider.value = music_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		print("Volume", master_volume, sfx_volume, music_volume)
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
	aim_senstivity = value

func _on_keybinds_button_pressed() -> void:
	$OptionsPanel.hide()
	$KeybindMenu.show()

func _on_exit_button_pressed() -> void:
	closed.emit()
	print("Options Menu!")
	$KeybindMenu.hide()
	hide()
	$OptionsPanel.show()


func _on_keybind_menu_closed() -> void:
	$OptionsPanel.show()
	$KeybindMenu.hide()
