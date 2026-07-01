extends Control

@export var buff_packed : PackedScene

@onready var buff_list : HBoxContainer = $BuffList

#var current_buffs : Array[Dictionary] = [] # Used to queue buffs that are activated but all current display slots are full
var current_buffs : Dictionary[String,HUDBuff]

func add_buff(tmp_name : String, duration : float = 0, image : Texture = null) -> void:
	# Checks if the buff is already active. Due to mutliple fish being able to be collected
	Debug.log("Adding buff: %s" % tmp_name)
	
	if current_buffs.has(tmp_name):
		var existing_buff : HUDBuff = current_buffs.get(tmp_name)
		existing_buff.buff_progress = 0
		return
	
	var new_buff : HUDBuff = buff_packed.instantiate()
	new_buff.buff_ended.connect(remove_buff)
	new_buff.start_buff(tmp_name,duration,image)
	buff_list.add_child(new_buff)
	current_buffs.set(tmp_name,new_buff)
	
	
func remove_buff(buff_name : String) -> void:
	print("buff ", buff_name, " removed")
	if not current_buffs.has(buff_name):
		return
	
	var expired_buff : HUDBuff = current_buffs.get(buff_name)
	expired_buff.queue_free()
	current_buffs.erase(buff_name)
	
	##This is an evil way to do this for several reasons, but tbh it's too much work to restructure so much code
	var c : ServerConnection = Multiplayer.player_list.get(multiplayer.get_unique_id())
	if c != null and c.player != null:
		c.player.remove_item_buff(buff_name)

func update_buffs(delta : float) -> void:
	for buff : HUDBuff in current_buffs.values():
		buff.update_buff(delta)
