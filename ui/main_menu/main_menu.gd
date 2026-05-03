extends Control

@export var options_song: Song
@export var fishdex_song: Song
@export var lobby_browse_song: Song

# Hide Everything that isn't the Main Menu
func _ready() -> void:
	Keybinds.load_keybinds()
	$LobbyBrowser.hide()
	$Fishdex.hide()
	$OptionsMenu.hide()

# Menu Buttons
func find_lobby_pressed() -> void:
	Multiplayer.scan_for_servers = true
	$MainMenuContainer.hide()
	$LobbyBrowser.show()
	MainMusicPlayer.push_song(lobby_browse_song, 0.0, 0.0)

func quit_pressed() -> void:
	get_tree().quit()

func fishdex_pressed() -> void:
	$MainMenuContainer.hide()
	$Fishdex.show()
	MainMusicPlayer.push_song(fishdex_song, 0.0, 0.0)

func itemdex_pressed() -> void:
	$MainMenuContainer.hide()
	$Itemdex.show()
	MainMusicPlayer.push_song(fishdex_song, 0.0, 0.0)

func settings_pressed() -> void:
	$MainMenuContainer.hide()
	$OptionsMenu.show()
	MainMusicPlayer.push_song(options_song, 0.0, 0.0)

# When returning to Main Menu from LobbyBrowser
func _on_lobby_browser_closed() -> void:
	Multiplayer.scan_for_servers = false
	$LobbyBrowser.hide()
	$MainMenuContainer.show()
	MainMusicPlayer.pop_song(0.0, 0.0, 0.0)

# When returnign to Main Menu from Fishdex
func _on_fishdex_closed() -> void:
	$Fishdex.hide()
	$MainMenuContainer.show()
	MainMusicPlayer.pop_song(0.0, 0.0, 0.0)
	
# When returning to Main Menu from Fishdex
func _on_itemdex_closed() -> void:
	$Itemdex.hide()
	$MainMenuContainer.show()
	MainMusicPlayer.pop_song(0.0, 0.0, 0.0)

# When returning to Main Menu from Settings
func _on_options_closed() -> void:
	$OptionsMenu.hide()
	$MainMenuContainer.show()
	MainMusicPlayer.pop_song(0.0, 0.0, 0.0)
