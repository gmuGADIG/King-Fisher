extends Node

const SECONDS_TO_MS : float = 1000.0
const MS_TO_SECONDS : float = 0.001
const BPM_TO_BPS : float = 1.0/60.0
const BPS_TO_BPM : float = 60.0

@onready var timer : Timer = $Timer

#@export var beats_per_minute : int = 140
#@export var offset_ms : int = 0
## The track currently being played. Should be null if not playing any track.
var current_track : Track
## The time at which track playback started
var start_time_ms : float
## The amount of delay caused by software & hardware
var audio_delay_ms : float
## The current time into the song 
var current_time_ms : float = 0

var current_beat : int = 0
var beats_per_second : float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(preload("res://systems/rhythm/tracks/track_common_1.tres"))

## Starts 
func play(track : Track) -> void:
	current_track = track
	audio_delay_ms = 1000*(AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
	##TODO: Add manual offset based on the player's settings
	current_time_ms = -audio_delay_ms
	##TODO: Play backing track

func stop() -> void:
	current_track = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_track != null:
		current_time_ms += 1000*delta

## Converts the number of beats into the song into the number of ms into the song
func beat_to_ms(beat : float) -> float:
	assert(current_track != null, "No track selected!")
	return (beat * SECONDS_TO_MS * BPS_TO_BPM) / current_track.bpm

## Converts the number of ms into the song into the number of beats into the song
func ms_to_beat(ms : float) -> float:
	assert(current_track != null, "No track selected!")
	return ms * MS_TO_SECONDS * current_track.bpm * BPM_TO_BPS
