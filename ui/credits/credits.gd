class_name Credits
extends Node2D

class CreditData:
	var size : int
	var text : String
	
	func get_font_size() -> int:
		match size:
			1:
				return 100
			2:
				return 80
			3: 
				return 50
			_:
				assert(false,"invalid size")
				return -1
	
	func _to_string() -> String:
		return str(size, " - ", text)
	
@export_multiline var credits_raw : String



@export var credits_text_packed : PackedScene

@export_category("Credit Timings")
@export var time_between_credits : float = 10
@export var credits_duration : float = 6

var credits_data : Array[CreditData]


var current_header : CreditText
var keep_header : bool = true

@onready var credits_timer : Timer = $CreditsTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits_timer.wait_time = time_between_credits
	credits_timer.start()
	
	
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
	
	
	
	await get_tree().create_timer(credits_duration).timeout
	for child in $CreditsAnchor.get_children():
		if child is CreditText:
			child.to_letter_rigid()
	
	if not keep_header:
		current_header.to_letter_rigid()
		current_header = null
	

func generate_next_credits_group() -> void:
	if credits_data.size() == 0:
		return
	
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel()
	
	##Check if header needs to be changed
	if current_header == null:
		var header_data : CreditData = credits_data.pop_front()
		assert(header_data.size <= 2, "not header?")
		var new_header : CreditText = create_credit_text(header_data)
		new_header.position = 150*Vector2.UP
		tween.tween_property(new_header,"position",Vector2.ZERO,1.0)
		current_header = new_header
		keep_header = true
		$HeaderAnchor.add_child(new_header)
	
	##Up to 5 lines of credits at a time
	for i in 5:
		if credits_data.size() == 0:
			break
		var current_data : CreditData = credits_data[0]
		
		##If next credit line is title, it should be skipped (unless alone)
		if current_data.size <= 2:
			break
		
		credits_data.pop_front()
		
		##Create the line of text
		var new_credit_text : CreditText = create_credit_text(current_data)
		var target_position : Vector2 = Vector2(0,i*current_data.get_font_size())
		
		new_credit_text.position = target_position + 2000*Vector2.LEFT
		if i % 2 == 1:
			new_credit_text.position.x = -new_credit_text.position.x
		
		tween.tween_property(new_credit_text,"position",target_position,1.5)
		
		$CreditsAnchor.add_child(new_credit_text)
	
	if credits_data[0].size <= 2:
		keep_header = false

func create_credit_text(credit_data : CreditData) -> CreditText:
	var new_credit_text : CreditText = credits_text_packed.instantiate()
	new_credit_text.label.text = credit_data.text
	new_credit_text.label.add_theme_font_size_override("font_size",credit_data.get_font_size())
	return new_credit_text
