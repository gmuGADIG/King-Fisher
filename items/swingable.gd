class_name SwingableItem extends Item

var spin: Tween
var holder: Node3D
var swing_active: bool = false
var hitPlayers: Array[Player] = []

func use():
	if !is_held: Debug.log_err("Something is wrong")
	else:
		if get_node_or_null("SwingSound"):
			$SwingSound.play()
		swing_active = true
		holder = get_parent_node_3d()
		Debug.log("Swing swing swing")
		position += Vector3.FORWARD
		spin = create_tween().set_parallel()
		spin.tween_property(
			holder, "rotation_degrees:y", 360, 0.4
		).as_relative().set_ease(Tween.EASE_OUT)
		# The item spins around because it's parented to the body, which spins.
		spin.finished.connect(queue_free)

## This function is connected to the item entering a body!p
## If the item is held, and the body entered is not the holder,
## do something to them. (Override this in a child class.)
func effect_on_contact(body: Node3D):
	if is_held and body.is_in_group("Player") and body != holder:
		Debug.log("Doing something to %s!" % body.name)

func _on_swing_hitbox_body_entered(body):
	
	if swing_active && !hitPlayers.has(body): 
		hitPlayers.append(body)
		effect_on_contact(body)
