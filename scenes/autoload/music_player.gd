extends AudioStreamPlayer

@export var music_playlist: Array[AudioStream]

var current_index: int = 0

func _ready() -> void:
	finished.connect(on_finished)
	
	# Start playing the first track immediately if available
	if music_playlist.size() > 0:
		play_track()


func play_track() -> void:
	if music_playlist.is_empty():
		return
	
	stream = music_playlist[current_index]
	play()


func on_finished() -> void:
	# Advance to next track, looping back to 0
	current_index = (current_index + 1) % music_playlist.size()
	play_track()
	
