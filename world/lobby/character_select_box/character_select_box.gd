extends Area3D

@onready var outline_1 : MeshInstance3D = $StorageSeatMesh/storage/Outline1
@onready var outline_2 : MeshInstance3D = $StorageSeatMesh/seatStorage/Outline2

func _on_body_entered(body: Node3D) -> void:
	outline_1.show()
	outline_2.show()
	#if body is Player:
		#if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			#return
		#CharacterSelect.open()
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in get_overlapping_bodies():
			if body is Player:
				if multiplayer.get_unique_id() != body.get_multiplayer_authority():
					return
				CharacterSelect.open()
				break

func _on_body_exited(body: Node3D) -> void:
	outline_1.hide()
	outline_2.hide()
	#if body is Player:
		#print("NEW HUMAN")
		#if multiplayer.get_unique_id() != body.get_multiplayer_authority():
			#return
		#CharacterSelect.close()
