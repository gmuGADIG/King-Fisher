extends Control

var all_tracks : Array[Track]


var last_track_index : int = 0
var random_mode : bool = true 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_tracks.append_array($FishingMiniGame.leftovers_tracks)
	all_tracks.append_array($FishingMiniGame.fresh_tracks)
	all_tracks.append_array($FishingMiniGame.premium_tracks)
	all_tracks.append_array($FishingMiniGame.sushi_tracks)
	
	$Start.show()
	$FishingMiniGame.hide()
	$FishingMiniGame.force_track_play_on_load = true

func _on_start_pressed() -> void:
	var manual_text : String = $Start/VBoxContainer/LineEdit.text
	if manual_text != "":
		##Find
		for i in all_tracks.size():
			var track : Track = all_tracks[i]
			if track.resource_path.contains(manual_text):
				print("aaaa")
				pick_new_track(i)
	else:
		pick_new_track()

func pick_new_track(track_index : int = -1) -> void:
	$Start.hide()
	var i : int
	if track_index > -1:
		i = track_index
	elif random_mode:
		i = randi_range(0,all_tracks.size()-1)
	else:
		i = (last_track_index + 1) % all_tracks.size()
	var track : Track = all_tracks[i]
	
	print("Track index: ", i)
	$FishingMiniGame.forced_track = track
	$FishingMiniGame.show()
	$FishingMiniGame.start(load("res://fish/fresh/angle_r_fish.tres"))
	last_track_index = i

func _on_fishing_mini_game_fishing_finished(success: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$FishingMiniGame/Accuracy.text = "Last Accuracy: " + str("%.2f" % $FishingMiniGame.calculate_accuracy()) + "%"
	pick_new_track()




func _on_pause_toggled(toggled_on: bool) -> void:
	get_tree().paused = toggled_on
	#print("AAA")
	#$FishingMiniGame.process_mode = Node.PROCESS_MODE_DISABLED
	#print("AAA")


func _on_mode_toggled(toggled_on: bool) -> void:
	random_mode = toggled_on
	if toggled_on:
		$FishingMiniGame/VBoxContainer/HBoxContainer/Previous.hide()
		$FishingMiniGame/VBoxContainer/HBoxContainer/Skip.text = "Skip"
		$FishingMiniGame/VBoxContainer/HBoxContainer2/Mode.text = "Mode: Random"
	else:
		$FishingMiniGame/VBoxContainer/HBoxContainer/Previous.show()
		$FishingMiniGame/VBoxContainer/HBoxContainer/Skip.text = "Next"
		$FishingMiniGame/VBoxContainer/HBoxContainer2/Mode.text = "Mode: Sequential"

func _on_previous_pressed() -> void:
	$FishingMiniGame.finish()
	
	var i : int = last_track_index - 1
	if i < 0:
		i = all_tracks.size()-1
	pick_new_track(i)
	
func _on_skip_pressed() -> void:
	$FishingMiniGame.finish()
	pick_new_track()
