extends Node2D

class CreditData:
	var size : int
	var text : String
	
	func get_font_size() -> int:
		match size:
			1:
				return 100
			2:
				return 72
			3: 
				return 50
			_:
				assert(false,"invalid size")
				return -1
	
	func _to_string() -> String:
		return str(size, " - ", text)
	
@export_multiline var credits_raw : String

@export var credits_text_packed : PackedScene

var credits_data : Array[CreditData]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in credits_raw.split("\n"):
		var new_data : CreditData = CreditData.new()
		var line_data : PackedStringArray = c.split("~")
		new_data.size = int(line_data[0])
		new_data.text = line_data[1]
		credits_data.append(new_data)
	
	#await get_tree().create_timer(1.0).timeout
	#$CreditsText.to_letter_rigid()
	_on_credits_timer_timeout()

func _on_credits_timer_timeout() -> void:
	print("AAA")
	generate_next_credits_group()
	
	await get_tree().create_timer(2.0).timeout
	for child in $CreditsText.get_children():
		if child is CreditText:
			child.to_letter_rigid()

func generate_next_credits_group() -> void:
	if credits_data.size() == 0:
		return
		
	##Up to 6 lines of credits at a time
	for i in 6:
		if credits_data.size() == 0:
			break
		var current_data : CreditData = credits_data[0]
		
		##If next credit line is title, it should be skipped (unless alone)
		if current_data.size == 1 and i != 0:
			break
		
		credits_data.pop_front()
		
		##Create the line of text
		var new_credit_text : CreditText = credits_text_packed.instantiate()
		new_credit_text.label.text = current_data.text
		new_credit_text.label.add_theme_font_size_override("font_size",current_data.get_font_size())
		new_credit_text.position.y = 1*i*current_data.get_font_size()
		$CreditsText.add_child(new_credit_text)
		
		if current_data.size == 1 and i == 0:
			break
