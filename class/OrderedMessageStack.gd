class_name OrderedMessageStack
extends Reference

signal contents_changed

var _untimed_messages: MessageStack = MessageStack.new()
var _timed_messages: MessageStack = MessageStack.new()


func _init() -> void:
	var untimed_status: int = _untimed_messages.connect(
		"contents_changed", self, "_on_contents_changed"
	)
	var timed_status: int = _timed_messages.conntect(
		"contents_changed", self, "_on_contents_changed"
	)

	if untimed_status != OK or timed_status != OK:
		printerr("OrderedMessageStack will not track all messages.")


# Allocates the given size for all different types.
func set_size(size: int) -> void:
	_untimed_messages.set_size(size)
	_timed_messages.set_size(size)


func get_size() -> int:
	return _untimed_messages.get_size()


# Returns if there is no more room for any type of message.
func is_full() -> bool:
	return _untimed_messages.is_full() or _timed_messages.is_full()


# Returns if there are no messages of any type.
func is_empty() -> bool:
	return _untimed_messages.is_empty() and _timed_messages.is_empty()


func peek() -> Message:
	if not _timed_messages.is_empty():
		return _timed_messages.peek()
	return _untimed_messages.peek()


func pop() -> Message:
	if not _timed_messages.is_empty():
		return _timed_messages.pop()
	return _untimed_messages.pop()


func discard_top() -> void:
	if not _timed_messages.is_empty():
		_timed_messages.discard_top()
	else:
		_untimed_messages.discard_top()


func push(message: Message) -> bool:
	if message is TimedMessage:
		return _timed_messages.push(message)
	return _untimed_messages.push(message)


func clear() -> void:
	_timed_messages.clear()
	_untimed_messages.clear()


func get_first() -> Message:
	if not _untimed_messages.is_empty():
		return _untimed_messages.get_first()
	return _timed_messages.get_first()


func preserve_only_first() -> void:
	if _untimed_messages.is_empty():
		_timed_messages.preserve_only_first()
	else:
		_timed_messages.clear()
		_untimed_messages.preserve_only_first()


func _on_contents_changed() -> void:
	emit_signal("contents_changed")
