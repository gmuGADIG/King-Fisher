extends Node

enum State{
	NONE,
	PAUSE,
	LIVEWELL,
	SCOREBOARD,
	CHARACTER_SELECT,
	FISHING_MINIGAME,
	LOBBY_SETTINGS
}

var ui_state : State:
	set(val):
		if ui_state == State.LIVEWELL:
			Livewell.hide()
		
		ui_state = val
		match val:
			State.NONE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				player_keyboard_input_blocked = false
				player_mouse_input_blocked = false
				player_click_input_blocked = false
				more_ui_blocked = false
			State.LIVEWELL, State.SCOREBOARD:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				player_keyboard_input_blocked = false
				player_mouse_input_blocked = false
				player_click_input_blocked = false
				more_ui_blocked = true
			State.PAUSE, State.FISHING_MINIGAME, State.LOBBY_SETTINGS:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				player_keyboard_input_blocked = true
				player_mouse_input_blocked = true
				player_click_input_blocked = true
				more_ui_blocked = true
			State.FISHING_MINIGAME:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				player_keyboard_input_blocked = true
				player_mouse_input_blocked = true
				player_click_input_blocked = true
				more_ui_blocked = true
			State.CHARACTER_SELECT:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				player_keyboard_input_blocked = false
				player_mouse_input_blocked = true
				player_click_input_blocked = true
				more_ui_blocked = true

var player_keyboard_input_blocked : bool
var player_mouse_input_blocked : bool
var player_click_input_blocked : bool
var more_ui_blocked : bool
