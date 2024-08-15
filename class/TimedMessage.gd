class_name TimedMessage
extends Message

signal message_expired

var _expired: bool = false setget , is_expired


func _init(message: String, timer: SceneTreeTimer).(message) -> void:
	var connect_status: int = timer.connect("timeout", self, "_on_timeout")
	if connect_status != OK:
		printerr('Unable to create timed message "%s".' % _message)
		expire()


func _on_timeout() -> void:
	expire()


func expire() -> void:
	if not _expired:
		_expired = true
		emit_signal("message_expired")


func is_expired() -> bool:
	return _expired
