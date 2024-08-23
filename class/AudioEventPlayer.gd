# Switches between AudioStreams sent to the Player.
class_name AudioEventPlayer
extends Node

export var autoplay := false setget set_autoplay, get_autoplay
export var initial_stream: AudioStream = null setget set_initial_stream, get_initial_stream
export var reset_stream_on_change := false
export var supported_streams := 1 setget set_supported_streams, get_supported_streams

var play_desired := false setget set_play, will_play

var _player := AudioStreamPlayer.new()
var _streams := Stack.new()


class StreamInfo:
	var stream: AudioStream
	var position := 0.0

	func _init(audio: AudioStream) -> void:
		stream = audio


func _init() -> void:
	_streams.set_size(supported_streams)

	var streams_status: int = _streams.connect(
		"contents_changed", self, "_on_streams_contents_changed"
	)
	var player_status: int = _player.connect("finished", self, "_on_player_finished")

	if streams_status == OK and player_status == OK:
		add_child(_player)
	else:
		printerr("AudioEventPlayer unable to play audio.")


func reset() -> void:
	stop()
	_streams.clear()
	if initial_stream != null:
		set_initial_stream(initial_stream)


func set_autoplay(value: bool) -> void:
	autoplay = value
	if value:
		set_play(true)


func get_autoplay() -> bool:
	return autoplay


func set_initial_stream(value: AudioStream) -> void:
	var status: bool = _streams.push(StreamInfo.new(value))
	if status:
		initial_stream = value
	else:
		printerr("Unable to set up initial stream.")


func get_initial_stream() -> AudioStream:
	return initial_stream


func set_supported_streams(value: int) -> void:
	if value >= 0:
		supported_streams = value
		_streams.set_size(supported_streams)


func get_supported_streams() -> int:
	return supported_streams


func set_play(value: bool) -> void:
	if not play_desired and value:
		_player.play()
	if not value:
		_player.stop()
	play_desired = value
	_player.stream_paused = false


func will_play() -> bool:
	return play_desired


func play() -> void:
	set_play(true)


func stop() -> void:
	set_play(false)


func push(audio: AudioStream) -> bool:
	var info := StreamInfo.new(audio)

	if not reset_stream_on_change and _player.is_playing():
		_preserve_stream_duration()

	return _streams.push(info)


func _preserve_stream_duration() -> void:
	var played_stream_info: StreamInfo = _streams.pop()
	_player.stop()

	# It is possible that several AudioStreams have been pushed on.
	# In that case, the currently playing AudioStream has already been
	# handled.
	if played_stream_info == _player.stream:
		played_stream_info.position = _player.get_playback_position()

	var restore_stream: bool = _streams.push(played_stream_info, true)
	if not restore_stream:
		printerr("Failed to restore AudioStream. It has been lost.")


func pause() -> void:
	_player.stream_paused = true


func discard() -> void:
	_streams.discard_top()


func _on_streams_contents_changed() -> void:
	var stream_info: StreamInfo = _streams.pop()
	if stream_info != null:
		_player.stop()
		_player.stream_paused = false

		_player.stream = stream_info.stream
		if play_desired:
			_player.play(stream_info.position)

		stream_info.position = 0.0
		var reset_position: bool = _streams.push(stream_info, true)
		if not reset_position:
			printerr("Failed to reset AudioStream position. AudioStream has been lost.")


func _on_player_finished() -> void:
	var stream_info: StreamInfo = _streams.peek()
	if stream_info != null and stream_info.stream == _player.stream:
		_streams.discard_top()
