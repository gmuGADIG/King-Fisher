class_name Swatta
extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var swatta_used_msec := -INF

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "swatting":
		animation_player.play("RESET")
		
		if Time.get_ticks_msec() - swatta_used_msec < 150:
			_on_tool_used()
			swatta_used_msec = -INF
		
	elif anim_name == "RESET":
		pass
	else:
		push_error("unknown animation finished " + anim_name)

func _on_tool_used() -> void:
	if animation_player.current_animation == "swatting":
		swatta_used_msec = Time.get_ticks_msec()
	else:
		animation_player.play("swatting")
