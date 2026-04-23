class_name Item
extends Area3D

## This is the base item. The item as it exists in the player's hand, inventory, and lying around the world are all the same thing.
## Create an inherited scene from res://items/item_base.tscn, then create a script that extends Item with a unique use() function to create a new item.
## You can also change the item_name string in the inspector, which will probably show in the HUD.

@export var item_name: String = "Base Item"
@export var description: String = ""
@export var lore : String = ""
@export var sprite : Texture

var is_held: bool = false

# Tells the item spawner that it isn't lying around anymore.
# The item spawner only lets there be a certain max # of items around, so it needs to know when a slot opens
signal item_got_picked_up

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Items don't care about collisions if they're from non-players or if the item is already held.
	if is_held || !body.is_in_group("Player"): return
	if body.has_method("pick_up_item"): 
		item_got_picked_up.emit()
		# We call deferred because this is physics and getting picked up involves reparenting.
		# No fucking with the scene tree before physics is done happening!
		body.pick_up_item.call_deferred(self)
	else:
		Debug.log_err("Player does not have pick_up_item function!")

## The generic use function. You can write your own in a class that extends Item.
func use() -> void:
	if !is_held: Debug.log_err("Item was used while not held, WTF?")
	else:
		Debug.log("Base Item used.")
		queue_free()
