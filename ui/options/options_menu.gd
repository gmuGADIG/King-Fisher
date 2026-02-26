extends Control

@onready var audo_player : AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		print("Options Menu!")
		visible = not visible

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value / 30)
	audo_player.bus = "Master"
	audo_player.play()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value / 30)
	audo_player.bus = "SFX"
	audo_player.play()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value / 30)
	audo_player.bus = "Music"
	audo_player.play()
