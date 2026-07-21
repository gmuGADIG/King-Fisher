class_name RadioButton
extends Node2D

var _peers: Array[RadioButton]
@onready var _btn: Button = $Sense
@onready var _circle: Sprite2D = $Circle

var selected : bool = false:
	set(val):
		selected = val
		_circle.visible = selected
			

func _ready() -> void:
	for sibling in get_parent().get_children():
		if sibling is RadioButton and sibling != self:
			_peers.push_back(sibling)
	
	_btn.pressed.connect(func():
		for peer in _peers:
			peer.selected = false
		selected = true
	)

	selected = false
