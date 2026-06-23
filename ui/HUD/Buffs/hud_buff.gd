extends Control

var buff_name: String
var buff_image : Texture
var value : float = 0
var active : bool = false
var buff_duration : float = 0
var buff_progress : float = 0

signal buff_ended(buff_slot : Control)

func _ready() -> void:
	$Placeholder.hide()

func start_buff(tmp_name: String, duration : float = 0, image: Texture = null) -> void:
	active = true
	buff_name = tmp_name
	$Placeholder.text = buff_name
	buff_duration = duration

	if image != null:
		buff_image = image
		$ProgressBar.texture_under = buff_image
	show()

func end_buff() -> void:
	active = false
	buff_name = ""
	buff_image = null

	buff_progress = 0
	buff_duration = 0

	$Placeholder.text = ""
	$ProgressBar.texture_under = null
	buff_ended.emit(self)
	hide()

func update_buff(time : float) -> void:
	if !active : return
	
	if buff_progress <= 100:
		buff_progress = buff_progress + (time / buff_duration * 100)
		$ProgressBar.value = buff_progress
	else:
		end_buff()
