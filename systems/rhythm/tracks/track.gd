class_name Track extends Resource

@export var bpm : float = 100
##How many ms the first beat is into the backing track's playback
@export var backing_track : AudioStream
##The list of when the player needs to press inputs to the beat. 1 beat = 1 quarter note
@export var notes: Array[Note]
