class_name Item
extends Area3D

## This is the base item. 

@export var item_name: String = "Base Item"

var is_held: bool = false

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if is_held || !body.is_in_group("Player"): return
	if body.has_method("pick_up_item"): 
		body.pick_up_item.call_deferred(self)
	else:
		print("Player does not have pick_up_item function!")
	
	

func use() -> void:
	if !is_held: print("Item was used while not held, WTF?")
	else:
		print("Base Item used.")
		queue_free()
