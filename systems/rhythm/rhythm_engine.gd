extends Node
class_name RhythmEngine

const SECONDS_TO_MS : float = 1000.0
const MS_TO_SECONDS : float = 0.001
const BPM_TO_BPS : float = 1.0/60.0
const BPS_TO_BPM : float = 60.0

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

@onready var tempo_audio_stream : AudioStreamPlayer = $"../TempoAudioStream"

## Starts 
func play(track : Track) -> void:
	current_track = track
	audio_delay_ms = 1000*(AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
	##TODO: Add manual offset based on the player's settings
	current_time_ms = -audio_delay_ms
	##TODO: Play backing track
	tempo_audio_stream.stream = track.backing_track
	tempo_audio_stream.play()
	

func stop() -> void:
	current_track = null
	tempo_audio_stream.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_track != null:
		current_time_ms += 1000*delta

## Converts the number of beats into the song into the number of ms into the song
func beat_to_ms(beat : float) -> float:
	assert(current_track != null, "No track selected!")
	return (((beat - 1.0) * BPS_TO_BPM) / current_track.bpm) * SECONDS_TO_MS

## Converts the number of ms into the song into the number of beats into the song
func ms_to_beat(ms : float) -> float:
	assert(current_track != null, "No track selected!")
	return ms * MS_TO_SECONDS * current_track.bpm * BPM_TO_BPS
