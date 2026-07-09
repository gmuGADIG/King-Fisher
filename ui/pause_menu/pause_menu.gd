extends Control

@onready var anim : AnimationPlayer = $PauseFish/TextureRect/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if UIState.more_ui_blocked and UIState.ui_state != UIState.State.PAUSE:
			return
		if $OptionsMenu.visible:
			$OptionsMenu._on_exit_button_pressed()
		
		if not visible:
			pause()
		else:
			unpause()
		await anim.animation_finished

func pause() -> void:
	UIState.ui_state = UIState.State.PAUSE
	visible = true
	anim.play("drop_down")


func unpause() -> void:
	anim.play("pull_up",0.5)
	await anim.animation_finished
	UIState.ui_state = UIState.State.NONE
	visible = false


func _on_quit_pressed() -> void:
	Multiplayer.disconnect_from_game()
	visible = false

func _on_continue_pressed() -> void:
	unpause()


func _on_settings_pressed() -> void:
	$OptionsMenu.closed.connect(func():
		$PauseFish.show()
	)
	$PauseFish.hide()
	$OptionsMenu.show()
