class_name MessageStack
extends Reference

signal contents_changed

var _max_messages: int = 0
var _messages: Array = []
var _num_messages: int = 0 setget , get_size


func set_size(size: int) -> void:
	_messages.resize(size)
	_max_messages = size


func get_size() -> int:
	return _num_messages


func is_full() -> bool:
	return _num_messages == _max_messages


func is_empty() -> bool:
	return _num_messages == 0


func peek() -> Message:
	if _pop_expired_messages() > 0:
		emit_signal("contents_changed")
	if _num_messages > 0:
		return _messages[_num_messages - 1]
	return null


func pop() -> Message:
	var message: Message = null
	if _num_messages > 0:
		_num_messages -= 1
		message = _messages[_num_messages]
		# warning-ignore: return_value_discarded
		_pop_expired_messages()
		emit_signal("contents_changed")
	return message


func discard_top() -> void:
	# warning-ignore: return_value_discarded
	pop()


func push(message: Message) -> bool:
	if is_full():
		return false
	if message is TimedMessage:
		var connect_status: int = message.connect("message_expired", self, "_on_message_expired")
		if connect_status != OK or message.is_expired():
			return false
	_messages[_num_messages] = message
	_num_messages += 1
	emit_signal("contents_changed")

	return true


func clear() -> void:
	_num_messages = 0
	emit_signal("contents_changed")


func get_first() -> Message:
	if _num_messages > 0:
		return _messages[0]
	return null


func preserve_only_first() -> void:
	_num_messages = 1
	emit_signal("contents_changed")


func _on_message_expired() -> void:
	var num_popped: int = _pop_expired_messages()
	if num_popped > 0:
		emit_signal("contents_changed")


func _pop_expired_messages() -> int:
	var message_popped: bool = true
	var num_popped: int = 0
	while message_popped:
		message_popped = _pop_expired_message() != null
		if message_popped:
			num_popped += 1
	return num_popped


func _pop_expired_message() -> Message:
	var top_message_idx: int = _num_messages - 1
	var expired_message: Message = null

	if top_message_idx >= 0:
		var top_message: Message = _messages[top_message_idx]

		if top_message is TimedMessage and top_message.is_expired():
			expired_message = top_message
			_num_messages = top_message_idx

	return expired_message
