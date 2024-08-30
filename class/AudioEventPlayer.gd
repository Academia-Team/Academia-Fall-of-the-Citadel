# Switches between AudioStreams sent to the Player.
class_name AudioEventPlayer
extends Node

export var autoplay := false setget set_autoplay, get_autoplay
export var initial_stream: AudioStream = null setget set_initial_stream, get_initial_stream
export var reset_stream_on_change := false
export var supported_streams := 1 setget set_supported_streams, get_supported_streams

var play_desired := false setget set_play, will_play

var _player := AudioStreamPlayer.new()
var _streams := TriPriorityStack.new()


class StreamInfo:
	var stream: AudioStream
	var position := 0.0

	func _init(audio: AudioStream) -> void:
		stream = audio


func _init() -> void:
	_streams.set_global_size(supported_streams)

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
	var low_stack: OrderedStack = _streams.get_level(_streams.LOW_PRIORITY)
	if low_stack != null:
		var status: bool = low_stack.push(StreamInfo.new(value))
		if status:
			initial_stream = value
		else:
			printerr("Unable to set up initial stream.")
	else:
		printerr("Cannot access priority level used for initial stream.")


func get_initial_stream() -> AudioStream:
	return initial_stream


func set_supported_streams(value: int) -> void:
	if value >= 0:
		supported_streams = value
		_streams.set_global_size(supported_streams)


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


func push(audio: AudioStream, priority: int = _streams.MED_PRIORITY) -> bool:
	var info := StreamInfo.new(audio)

	if _player.is_playing():
		_preserve_stream_duration()
		_player.stop()

	var stack: OrderedStack = _streams.get_level(priority)

	return stack != null and stack.push(info)


func _preserve_stream_duration() -> void:
	for priority in range(_streams.NUM_PRIORITIES - 1, -1, -1):
		var stack: OrderedStack = _streams.get_level(priority)
		var played_stream_info: StreamInfo = stack.peek()
		# It is possible that several AudioStreams have been pushed on.
		# In that case, the currently playing AudioStream has already been
		# handled.
		if played_stream_info != null and played_stream_info.stream == _player.stream:
			stack.discard_top()
			played_stream_info.position = _player.get_playback_position()

			var restore_stream: bool = stack.push(played_stream_info, true)
			if not restore_stream:
				printerr("Failed to restore AudioStream in priority level %d." % priority)


func pause() -> void:
	_player.stream_paused = true


func discard() -> void:
	_streams.discard_top()


func _on_streams_contents_changed() -> void:
	var stream_info: StreamInfo = _streams.peek()
	if stream_info != null:
		_player.stop()
		_player.stream_paused = false

		_player.stream = stream_info.stream
		if play_desired:
			_player.play(stream_info.position if not reset_stream_on_change else 0.0)


func _on_player_finished() -> void:
	var stream_info: StreamInfo = _streams.peek()
	if stream_info != null and stream_info.stream == _player.stream:
		_streams.discard_top()
