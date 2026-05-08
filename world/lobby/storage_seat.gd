class_name StorageSeat extends Node3D

@onready var interactable_area: Area3D = $InteractableArea
var player_texture_manager: PlayerTextureManager

func _on_interactable_area_body_entered(body: Node3D) -> void:
	if body.get_parent_node_3d().is_in_group("Player"):
		player_texture_manager = body.get_parent_node_3d().get_node("PlayerTextureManager")

func _on_interactable_area_body_exited(body: Node3D) -> void:
	if body.get_parent_node_3d().is_in_group("Player"):
		player_texture_manager = null
