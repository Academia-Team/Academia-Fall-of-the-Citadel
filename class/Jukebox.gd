class_name Jukebox
extends AudioStreamPlayer

signal next_song(song_index)

export(Array, AudioStream) var music: Array
var _index: int = 0
var _pos: float = 0


func _ready() -> void:
	var connect_status: int = connect("finished", self, "_on_finished")

	if connect_status != OK:
		printerr("Internal Jukebox Failure.")

	if autoplay:
		start()


func start(start_index: int = _index, position: float = 0) -> void:
	if start_index >= music.size():
		printerr("Error starting Jukebox: Index %d is out of range." % start_index)
	else:
		stream = music[start_index]
		play(position)


func end() -> void:
	stop()
	_index = 0
	_pos = 0


func pause() -> void:
	_pos = get_playback_position()
	stop()


func resume() -> void:
	start(_index, _pos)
	_pos = 0


func _on_finished() -> void:
	var next_index = (_index + 1) % music.size()
	start(next_index)
	emit_signal("next_song", next_index)
	_index = next_index
