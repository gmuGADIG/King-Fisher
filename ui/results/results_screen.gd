class_name ResultsScreen
extends Node3D

# can be 1, 2, 3, or 4
static var placements : Array[int]
static var scores : Array[int]

@onready var label: Label = %PlacementLabel

@export var player_meshes : Array[MeshInstance3D]
@export var player_labels : Array[Label3D]
@export var score_labels : Array[Label3D]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for placement in placements.size():
		var player_id : int = placements[placement]
		if player_id == multiplayer.get_unique_id():
			set_placement(placement)
		##Hide empties
		if player_id == -1 or not Multiplayer.player_list.has(player_id):
			player_meshes[placement].hide()
			player_labels[placement].hide()
			score_labels[placement].hide()
		else:
			player_meshes[placement].show()
			player_labels[placement].show()
			score_labels[placement].text = str(scores[placement],"¤")
			score_labels[placement].show()
			
				
			var tex_id : int = Multiplayer.player_list[player_id].character_texture_id
			var player_mat : StandardMaterial3D = player_meshes[placement].material_override
			player_mat.albedo_texture = CharacterSelect.character_textures[tex_id]
			player_labels[placement].text = Multiplayer.player_list[player_id].playerName


func set_placement(placement : int) -> void:
	match placement:
		0: label.text = "1st place"
		1: label.text = "2nd place"
		2: label.text = "3rd place"
		3: label.text = "4th place"
	
	
func _on_continue_button_pressed() -> void:
	if not multiplayer.is_server():
		return
	
	#Multiplayer.
	send_all_to_lobby.rpc()
	

@rpc("authority","call_local","reliable")
func send_all_to_lobby() -> void:
	WorldBase.returning_to_lobby = true
	SceneTransition.change_to_file("res://world/lobby/lobby.tscn")
