class_name OrderedMessageStack
extends Reference

signal contents_changed

var _untimed_messages := Stack.new()
var _timed_messages := Stack.new()


func _init() -> void:
	var untimed_status: int = _untimed_messages.connect(
		"contents_changed", self, "_on_contents_changed"
	)
	var timed_status: int = _timed_messages.connect(
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


func peek() -> String:
	if not _timed_messages.is_empty():
		return _timed_messages.peek().get_item()
	return _untimed_messages.peek()


func pop() -> String:
	if not _timed_messages.is_empty():
		return _timed_messages.pop().get_item()
	return _untimed_messages.pop()


func discard_top() -> void:
	if not _timed_messages.is_empty():
		_timed_messages.discard_top()
	else:
		_untimed_messages.discard_top()


func push(message) -> bool:
	if message is String:
		return _untimed_messages.push(message)
	if message is Expirable and message.get_item() is String:
		return _timed_messages.push(message)
	return false


func clear() -> void:
	_timed_messages.clear()
	_untimed_messages.clear()


func get_first() -> String:
	var value := ""
	if not _untimed_messages.is_empty():
		value = _untimed_messages.get_first()
	elif not _timed_messages.is_empty():
		var timed_message: Expirable = _timed_messages.get_first()
		if timed_message != null:
			value = timed_message.get_item()
		value = _timed_messages.get_first().get_item()
	return value


func preserve_only_first() -> void:
	if _untimed_messages.is_empty():
		_timed_messages.preserve_only_first()
	else:
		_timed_messages.clear()
		_untimed_messages.preserve_only_first()


func _on_contents_changed() -> void:
	emit_signal("contents_changed")
