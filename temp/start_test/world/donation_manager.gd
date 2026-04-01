extends CanvasLayer

enum State {
	POLL_DONATION,
	READING_MESSAGE,
	IDLE,
	RETURN
}

var window_visible := false

@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var label: RichTextLabel = %RichTextLabel
@onready var fmt: String = label.text

func _anim_return_finished() -> void:
	window_visible = false


func _on_close_button_pressed() -> void:
	if Tool.held_tool == null and not anim.is_playing():
		anim.play("return")
