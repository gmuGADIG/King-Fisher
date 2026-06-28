class_name CreditText
extends Node2D

@export var letter_rigid_packed : PackedScene
@export var label : Label


func to_letter_rigid() -> void:
	
	var text : String = label.text
	var font_size : float = label.get_theme_font_size("font_size")
	print(font_size)
	for i in text.length():
		var letter : String = text[i]
		if letter == " ":
			continue
		
		var pos : Vector2 = Vector2(
			font_size*0.54*(i+0.5-text.length()*0.5),
			0
		)
		var new_rigid : LetterRigid = letter_rigid_packed.instantiate()
		new_rigid.position = position+pos
		new_rigid.letter.text = text[i]
		
		new_rigid.letter.add_theme_font_size_override("font_size",font_size)
		new_rigid.collision_shape.shape.radius = font_size*0.25
		
		add_sibling(new_rigid)
		
		
		
	queue_free()
