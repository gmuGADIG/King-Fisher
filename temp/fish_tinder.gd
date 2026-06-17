extends Control

@export var all_tracks : Array[Track]

var last_track : Track

var track_elo : Dictionary[Track,int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for track in all_tracks:
		track_elo[track] = 0
		
	$Start.show()
	$Choice.hide()
	$FishingMiniGame.hide()
	$FishingMiniGame.force_track_play_on_load = true


func pick_new_track() -> void:
	$Start.hide()
	$Choice.hide()
	$FishingMiniGame.forced_track = all_tracks.pick_random()
	$FishingMiniGame.show()
	$FishingMiniGame.start(load("res://fish/fresh/angle_r_fish.tres"))


func _on_fishing_mini_game_fishing_finished(success: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if last_track == null:
		print("again!")
		last_track = $FishingMiniGame.forced_track
		pick_new_track()
	else:
		$Choice.show()


func _on_first_pressed() -> void:
	track_elo[last_track] += 1
	track_elo[$FishingMiniGame.forced_track] -= 1
	last_track = null
	pick_new_track()

func _on_second_pressed() -> void:
	track_elo[last_track] -= 1
	track_elo[$FishingMiniGame.forced_track] += 1
	last_track = null
	pick_new_track()


func _on_save_and_quit_pressed() -> void:
	for track in all_tracks:
		if track_elo[track] != 0:
			print(track.resource_path,"#",track_elo[track])
