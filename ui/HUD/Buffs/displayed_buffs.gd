extends Control

@onready var buff_one : Control = $HBoxContainer/Buff_One
@onready var buff_two : Control = $HBoxContainer/Buff_Two
@onready var buff_three : Control = $HBoxContainer/Buff_Three

var buff_queue : Array[Dictionary] = [] # Used to queue buffs that are activated but all current display slots are full
var buff_item : Dictionary = { # Values stored to properly start up buffs when a slot opens
	"name" : "",
	"duration" : 0,
	"image" : null,
	"start_time" : 0
}

func add_buff(tmp_name : String, duration : float = 0, image : Texture = null) -> void:
	# Checks if the buff is already active. Due to mutliple fish being able to be collected
	Debug.log("Adding buff: %s" % tmp_name)
	Debug.log("Is %s active: %s" % [buff_one.buff_name, check_if_buff_active(tmp_name)])
	if check_if_buff_active(tmp_name) : return

	if !buff_one.active:
		buff_one.start_buff(tmp_name, duration, image)
	elif !buff_two.active:
		buff_two.start_buff(tmp_name, duration, image)
	elif !buff_three.active:
		buff_three.start_buff(tmp_name, duration, image)
	else:
		if buff_queue.size() > 0:
			for i in buff_queue:
				if i.name == tmp_name:
					i.start_time = Time.get_ticks_msec()
		else:
			var tmp_info = {
				"name" : tmp_name,
				"duration" : duration,
				"image" : image,
				"start_time" : Time.get_ticks_msec()
			}
			buff_item = tmp_info
			buff_queue.append(buff_item.duplicate())

func remove_buff(buff_name : String) -> void:
	if buff_one.buff_name == buff_name:
		buff_one.end_buff()
	elif buff_two.buff_name == buff_name:
		buff_two.end_buff()
	elif buff_three.buff_name == buff_name:
		buff_three.end_buff()
	else:
		for i in buff_queue:
			if i.name == buff_name:
				buff_queue.erase(i)

func check_if_buff_active(buff_name : String) -> bool:
	if buff_one.buff_name == buff_name or buff_two.buff_name == buff_name or buff_three.buff_name == buff_name:
		return true
	else:
		return false

func shift_buffs(buff_slot : Control) -> void:
	match buff_slot:
		buff_one:
			if buff_two.active:
				transfer_info(buff_two, buff_one)
				buff_two.end_buff()
				buff_two.hide()
		buff_two:
			if buff_three.active:
				transfer_info(buff_three, buff_two)
				buff_three.end_buff()
				buff_three.hide()
	if buff_one.active or buff_two.active or buff_three.active:
		if buff_queue.size () > 0:
			var tmp_buff = buff_queue.pop_front()
			add_buff(tmp_buff["name"], tmp_buff["duration"], tmp_buff["image"])

func transfer_info(source : Control, target : Control) -> void:
	target.buff_name = source.buff_name
	target.buff_image = source.buff_image
	target.active = source.active

func update_buffs(time_left : float) -> void:
	buff_one.update_buff(time_left)
	buff_two.update_buff(time_left)
	buff_three.update_buff(time_left)
