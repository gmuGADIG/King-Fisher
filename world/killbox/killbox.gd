class_name Killbox
extends Area3D

@export var killbox_enabled: bool = true
@export var force_respawn_delay : float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not killbox_enabled: return
	if body is Player:
		if body.force_respawn: return
		
		body.force_respawn = true
		if body.is_ragdolled: return
		body.ragdoll_phys.ragdoll(force_respawn_delay)
		await get_tree().create_timer(force_respawn_delay).timeout
		if not body.is_ragdolled: return
		body.ragdoll_phys.end_ragdoll()
		Debug.log("Killbox: " + body.name + " entered killbox, killing player.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
