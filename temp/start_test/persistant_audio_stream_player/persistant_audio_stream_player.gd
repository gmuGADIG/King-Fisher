class_name PersistantAudioStreamPlayer
extends AudioStreamPlayer

## Play this audio stream "persistantly" by making it a child
## of the scene, so the audio doesn't stop playing when the parent
## is freed.
func play_persistant(from_position: float = 0.0) -> void:
	var tree := get_tree()
	get_parent().remove_child(self)
	tree.current_scene.add_child(self)
	
	play(from_position)
