extends Node2D

@export var fish_textures : Array[Texture]

var fish_pool : Array[Texture]
@onready var animation_list : PackedStringArray = $FishAnimation.get_animation_list()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_fish_pool()

func set_up_fish_pool() -> void:
	fish_pool.clear()
	fish_pool.append_array(fish_textures)
	fish_pool.shuffle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_animation() -> void:
	
	if fish_pool.is_empty():
		set_up_fish_pool()
	$Fish1.texture = fish_pool.pop_back()
	
	print($Fish1.texture.resource_path)
	$FishAnimation.play(animation_list[randi_range(1,animation_list.size()-1)])
	
func _on_animation_finished(anim_name: StringName) -> void:
	pass
	#$Fish1.texture = fish_textures.pick_random()
	#$FishAnimation.play(animation_list[randi_range(0,animation_list.size()-1)])
