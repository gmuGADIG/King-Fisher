extends Node

@export var song: Song

## Decides whether or not to reset the song playing, if the song currently 
## playing is the song specified by [member song].
@export var reset_song := false

## Whether to fade in the new song or play it immediately
@export var immediate := false

func _ready() -> void:
	if not song:
		return
	
	var is_same_song : bool = MainMusicPlayer.get_current_song() == song
	if reset_song or not is_same_song:
		MainMusicPlayer.clear_stack()
		if not immediate:
			MainMusicPlayer.play_song(song)
		else:
			MainMusicPlayer.play_song(song, 0.0, 0.0)
