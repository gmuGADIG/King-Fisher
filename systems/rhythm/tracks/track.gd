class_name Track extends Resource

@export var bpm : float = 100
##How many ms the first beat is into the backing track's playback
@export_range(0, 10000, 1, "suffix:ms") var song_start_time : float
##The amount of time early/late the player can hit the button to be "on rhythm"
@export_range(0, 500, 1, "suffix:ms") var hit_leniency : float = 50
##The backing track audio stream (drag in an mp3, wav, ogg, etc.)
@export var backing_track : AudioStream
##The list of when the player needs to press inputs to the beat. 1 beat = 1 quarter note
@export var notes: Array[Note]
