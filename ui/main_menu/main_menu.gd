extends Control

# Hide Everything that isn't the Main Menu
func _ready() -> void:
	get_tree().change_scene_to_file("res://temp/")
	$LobbyBrowser.hide()
	$Fishdex.hide()
	$OptionsMenu.hide()

# Menu Buttons
func find_lobby_pressed() -> void:
	Multiplayer.scan_for_servers = true
	$MainMenuContainer.hide()
	$LobbyBrowser.show()

func quit_pressed() -> void:
	get_tree().quit()

func fishdex_pressed() -> void:
	$MainMenuContainer.hide()
	$Fishdex.show()

func settings_pressed() -> void:
	$MainMenuContainer.hide()
	$OptionsMenu.show()

# When returning to Main Menu from LobbyBrowser
func _on_lobby_browser_closed() -> void:
	Multiplayer.scan_for_servers = false
	$LobbyBrowser.hide()
	$MainMenuContainer.show()

# When returnign to Main Menu from Fishdex
func _on_fishdex_closed() -> void:
	$Fishdex.hide()
	$MainMenuContainer.show()

# When returning to Main Menu from Settings
func _on_options_closed() -> void:
	$OptionsMenu.hide()
	$MainMenuContainer.show()
