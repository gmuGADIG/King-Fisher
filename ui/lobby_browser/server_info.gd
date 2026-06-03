@tool
extends PanelContainer
class_name ServerInfo

signal pressed

@export var ip: String = "192.168.1.1":
	set(v):
		ip = v
		if is_node_ready():
			#_update_ip_label()
			_update_serverinfo_label(%IPLabel, v)
@export var hostname: String = "Hostname":
	set(v):
		hostname = v
		if is_node_ready():
			_update_serverinfo_label(%NameLabel, v)
		
@export var playerCount: String = "0/0":
	set(v):
		playerCount = v
		if is_node_ready():
			_update_serverinfo_label(%CountLabel, v)
@export var status: String = "None":
	set(v):
		status = v
		if is_node_ready():
			_update_serverinfo_label(%StatusLabel, v)


func _update_serverinfo_label(label: Label, newString: String) -> void:
	label.text = newString


func _ready() -> void:
	_update_serverinfo_label(%NameLabel, hostname)
	_update_serverinfo_label(%CountLabel, playerCount)
	_update_serverinfo_label(%IPLabel, ip)
	_update_serverinfo_label(%StatusLabel, status)

func _on_join_button_pressed() -> void:
	pressed.emit()
