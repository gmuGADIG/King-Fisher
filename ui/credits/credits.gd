extends Node2D


@export var letter_rigidbody_packed : PackedScene

@export var random_angular : float
@export var random_linear : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CreditsAnimation.play("credits")
	await get_tree().create_timer(1.0).timeout
	text_to_rigidbody($Guy,$Guy/Label)


func text_to_rigidbody(guy : Node2D, label : Label) -> void:
	assert(label.get_parent() == guy, "invalid pairing")
	
	var text : String = label.text
	var font_size : float = label.get_theme_font_size("font_size")
	print(font_size)
	for i in text.length():
		var letter : String = text[i]
		if letter == " ":
			continue
		
		var pos : float = font_size*0.54*(i+0.5)
		var new_rigid : LetterRigid = letter_rigidbody_packed.instantiate()
		new_rigid.position = Vector2(guy.position.x+pos,guy.position.y)
		new_rigid.letter.text = text[i]
		new_rigid.letter.add_theme_font_size_override("font_size",font_size)
		add_child(new_rigid)
		
		##Random Force
		new_rigid.linear_velocity.y = randf_range(-random_linear.y,random_linear.y)
		new_rigid.linear_velocity.x = randf_range(-random_linear.x,random_linear.x)

		new_rigid.angular_velocity = randf_range(-random_angular,random_angular)
		#new_rigid.apply_torque_impulse(500)
		
	guy.queue_free()
