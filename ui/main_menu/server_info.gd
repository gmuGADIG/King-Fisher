@tool
extends PanelContainer
class_name ServerInfo

signal pressed

@export var ip: String = "192.168.1.1":
	set(v):
		ip = v
		if is_node_ready():
			_update_ip_label()

func _update_ip_label() -> void:
	%IPLabel.text = ip

func _ready() -> void:
	_update_ip_label()


func _on_join_button_pressed() -> void:
	pressed.emit()

