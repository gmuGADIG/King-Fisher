extends Control
class_name Options

static var mouse_sensitivity : float = 1
static var master_volume : float = 1
static var sfx_volume : float = 1
static var music_volume : float = 1

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		print("Options Menu!")
		visible = not visible

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value / 30)
	audio_player.bus = "Master"
	audio_player.play()
	master_volume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value / 30)
	audio_player.bus = "SFX"
	audio_player.play()
	sfx_volume = value
	
	
func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value / 30)
	audio_player.bus = "Music"
	audio_player.play()
	music_volume = value

func _on_mouse_sensitivty_slider_value_changed(value: float) -> void:
	mouse_sensitivity = value

func _on_button_pressed() -> void:
	closed.emit()
	print("Options Menu!")
	$".".hide()
