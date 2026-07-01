class_name Killbox
extends Area3D

@export var killbox_enabled: bool = true
@export var force_respawn_delay : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not killbox_enabled: return
	
	##This catches a case where the player is already ragdolled and falls in the water
	if body.name == "Physical Bone Pelvis":
		body = body.get_parent() # Get the Bones node from the pelvis bone
		body = body.player
	print(body)
	if body is not Player: return

	if !body.force_respawn:
		body.force_respawn = true
		if not body.is_ragdolled:
			body.ragdoll_phys.ragdoll(force_respawn_delay)
			Debug.log("Killbox: " + body.name + " entered killbox, killing player.")
			
		Debug.log("Killbox: Starting force respawn in " + str(force_respawn_delay) + " seconds for " + body.name + ".")
		await get_tree().create_timer(force_respawn_delay).timeout
		# Incase someone manages to respawn before the forced respawn.
		if not body.is_ragdolled: return
		body.ragdoll_phys.end_ragdoll()
