class_name RhythmSettings
extends Control

signal closed

static var manual_audio_offset : float
static var manual_video_offset : float

@onready var audio_offset_slider : HSlider = $RhythmPanel/VBoxContainer/VBoxContainer/AudioOffsetSlider

@onready var audio_offset_label : Label = $RhythmPanel/VBoxContainer/VBoxContainer/AudioOffsetLabel
@onready var video_offset_label : Label = $RhythmPanel/VBoxContainer/VBoxContainer/VideoOffsetLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FishingMiniGame.force_track_play_on_load = true
	%AccuracyLabel.text = ""
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_audio_offset_slider_value_changed(value: float) -> void:
	##Flipped so the left of the bar = early
	manual_audio_offset = -value
	audio_offset_label.text = str("Audio Offset: ",audio_timing_string(-value))

func _on_video_offset_slider_value_changed(value: float) -> void:
	manual_video_offset = value
	video_offset_label.text = str("Video Offset: ",visual_timing_string(value))
	
func _on_test_button_pressed() -> void:
	$RhythmPanel.hide()
	$FishingMiniGame.start(preload("res://fish/fresh/angle_r_fish.tres"))
	await $FishingMiniGame.fishing_finished
	var calculated_offset : float = $FishingMiniGame.calculated_offset
	
	if is_zero_approx(roundf(calculated_offset)):
		%AccuracyLabel.text = "You hit on time!"
	else:
		%AccuracyLabel.text = str(
			"You hit ~",audio_timing_string(calculated_offset)
		)
	$RhythmPanel.show()

func audio_timing_string(ms : float) -> String:
	var early_or_late : String
	if ms != 0:
		if ms < 0:
			early_or_late = "late"
		else:
			early_or_late = "early"
	
	return str("%.0f" % absf(ms), " ms ",early_or_late)

func visual_timing_string(ms : float) -> String:
	var left_or_right : String
	if ms != 0:
		if ms < 0:
			left_or_right = "left"
		else:
			left_or_right = "right"
	
	return str("%.1f" % absf(ms), " px ",left_or_right)


func _on_exit_button_pressed() -> void:
	closed.emit()

func load_settings(config : ConfigFile) -> void:
	manual_audio_offset = config.get_value("rhythm", "audio_offset", 0)
	audio_offset_slider.value = manual_audio_offset
