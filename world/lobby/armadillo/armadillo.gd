extends Area3D

@export var enable_sound : AudioStream
@export var disable_sound : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if not multiplayer.is_server():
			return
		if body.get_multiplayer_authority() == 1:
			set_armadillo_mode.rpc(not BananaPeel.armadillo_mode)

@rpc("reliable","call_local","authority")
func set_armadillo_mode(armadillo_mode : bool) -> void:
	if armadillo_mode:
		BananaPeel.armadillo_mode = true
		$AudioStreamPlayer3D.stream = enable_sound
		%Outline.show()
	else:
		BananaPeel.armadillo_mode = false
		$AudioStreamPlayer3D.stream = disable_sound
		%Outline.hide()
	
	$AudioStreamPlayer3D.play()
