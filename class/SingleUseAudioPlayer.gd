# Forces a stream to be only played one time.
# It is especially useful when targetting web, as audio could play too late due
# to browser autoplay restrictions.

class_name SingleUseAudioPlayer
extends Node

signal finished

export var autoplay: bool = false setget set_autoplay, get_autoplay
export var playing: bool = false setget , is_playing
export var stream: AudioStream = null setget set_stream, get_stream

var _player: AudioStreamPlayer
var _stop: bool = false


func _init() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)


func _ready() -> void:
	if autoplay:
		play()


func _process(_delta: float) -> void:
	if _stop and _player.get_playback_position() > 0.0:
		_player.stop()


func set_autoplay(value: bool) -> void:
	autoplay = value


func get_autoplay() -> bool:
	return autoplay


func is_playing() -> bool:
	return playing


func set_stream(value: AudioStream) -> void:
	stream = value
	_player.stream = stream


func get_stream() -> AudioStream:
	return stream


func play() -> void:
	if not playing:
		if stream != null:
			_player.play()
			playing = true

			var timer: SceneTreeTimer = get_tree().create_timer(stream.get_length())
			var connect_status: int = timer.connect("timeout", self, "_on_stream_timeout")
			if connect_status != OK:
				printerr("Unable to detect when stream finishes.")
		else:
			printerr("Unable to access audio stream.")


func stop() -> void:
	if not _stop:
		_player.stop()
		_stop = true
		playing = false
		emit_signal("finished")


func reset() -> void:
	_stop = false


func _on_stream_timeout() -> void:
	stop()
