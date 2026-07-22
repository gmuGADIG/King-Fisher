extends Control
class_name Options

static var config = ConfigFile.new()

static var mouse_sensitivity : float = 1
static var aim_senstivity : float = 1
#static var master_volume : float = 1:
	#set(val):
		#master_volume = val
		#AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), val)
static var sfx_volume : float = 1:
	set(val):
		sfx_volume = val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), val)
static var music_volume : float = 1:
	set(val):
		music_volume = val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), val)

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var mouse_sens_slider = $OptionsPanel/VBoxContainer/VBoxContainer/MouseSensitivtySlider
@onready var aim_sens_slider = $OptionsPanel/VBoxContainer/VBoxContainer/AimingSensitivitySlider
@onready var sfx_slider = $OptionsPanel/VBoxContainer/VBoxContainer/SFXSlider
@onready var music_slider = $OptionsPanel/VBoxContainer/VBoxContainer/MusicSlider

signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	update_sliders()
	#master_slider.value = master_volume
	hide()

func update_sliders() -> void:
	mouse_sens_slider.value = mouse_sensitivity
	aim_sens_slider.value = aim_senstivity
	sfx_slider.value = sfx_volume
	music_slider.value = music_volume
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		#print("Volume", master_volume, sfx_volume, music_volume)
		print("Options Menu!")
		visible = not visible

#func _on_master_slider_value_changed(value: float) -> void:
	#master_volume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_volume = value
	
func _on_music_slider_value_changed(value: float) -> void:
	music_volume = value

func _on_mouse_sensitivty_slider_value_changed(value: float) -> void:
	mouse_sensitivity = value

func _on_aim_sensitivty_slider_value_changed(value: float) -> void:
	aim_senstivity = value

func save_settings() -> void:
	config.set_value("options", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("options", "aim_sensitivity", aim_senstivity)
	config.set_value("options", "sfx_volume", sfx_volume)
	config.set_value("options", "music_volume", music_volume)
	config.set_value("rhythm", "audio_offset", RhythmSettings.manual_audio_offset)
	config.save("user://settings.cfg")
	Debug.log("Saving Settings")

func load_settings() -> void:
	var info = config.load("user://settings.cfg")
	if info != OK:
		print("No settings file found, using defaults")
		return
	mouse_sensitivity = config.get_value("options", "mouse_sensitivity", 1)
	aim_senstivity = config.get_value("options", "aim_sensitivity", 1)
	sfx_volume = config.get_value("options", "sfx_volume", 1)
	music_volume = config.get_value("options", "music_volume", 1)
	$RhythmSettings.load_settings(config) 
	
func _on_slider_released(_value : float) -> void:
	save_settings()

func _on_keybinds_button_pressed() -> void:
	$OptionsPanel.hide()
	$KeybindMenu.show()

func _on_exit_button_pressed() -> void:
	closed.emit()
	save_settings()
	print("Options Menu!")
	$KeybindMenu.hide()
	hide()
	$OptionsPanel.show()


func _on_keybind_menu_closed() -> void:
	$OptionsPanel.show()
	$KeybindMenu.hide()


func _on_reset_pressed() -> void:
	config.clear()
	mouse_sensitivity = 1
	aim_senstivity = 1
	sfx_volume = 1
	music_volume = 1
	update_sliders()
	save_settings()

func _on_rhythm_settings_closed() -> void:
	$OptionsPanel.show()
	$RhythmSettings.hide()
	$ExitButton.show()
	save_settings()


func _on_rhythm_settings_pressed() -> void:
	$OptionsPanel.hide()
	$RhythmSettings.show()
	$ExitButton.hide()
