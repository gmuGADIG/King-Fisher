extends Node2D

@export var fish_textures : Array[Texture]

@onready var animation_list : PackedStringArray = $FishAnimation.get_animation_list()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_animation() -> void:
	print("playing!!")
	$Fish1.texture = fish_textures.pick_random()
	print($Fish1.texture.resource_path)
	$FishAnimation.play(animation_list[randi_range(1,animation_list.size()-1)])
	
func _on_animation_finished(anim_name: StringName) -> void:
	pass
	#$Fish1.texture = fish_textures.pick_random()
	#$FishAnimation.play(animation_list[randi_range(0,animation_list.size()-1)])
