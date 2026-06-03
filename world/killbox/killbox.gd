class_name Killbox
extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if body.force_respawn: return
		if !body.force_respawn:
			body.force_respawn = true
			if body.is_ragdolled: return
			body.ragdoll_phys.ragdoll(.05)
			Debug.log("Killbox: " + body.name + " entered killbox, killing player.")
	elif body.name == "Physical Bone Pelvis":
		body = body.get_parent() # Get the Bones node from the pelvis bone
		body = body.player
		if body.force_respawn: return
		if !body.force_respawn:
			body.force_respawn = true
			Debug.log("Killbox: " + body.name + " entered killbox, killing player.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
