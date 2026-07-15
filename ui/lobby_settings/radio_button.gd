class_name RadioButton
extends Node2D

var _peers: Array[RadioButton]
@onready var _btn: Button = $Sense
@onready var _circle: Sprite2D = $Circle

var selected := true

func _ready() -> void:
	for sibling in get_parent().get_children():
		if sibling is RadioButton and sibling != self:
			_peers.push_back(sibling)
	
	_btn.pressed.connect(func():
		for peer in _peers:
			peer.unselect()
		select()
	)

	unselect()

func select() -> void:
	_circle.show()
	pass

func unselect() -> void:
	_circle.hide()
	pass
