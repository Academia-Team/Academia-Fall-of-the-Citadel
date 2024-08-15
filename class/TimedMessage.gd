extends Node

signal message_expired

var _amount_time: float = 0.0
var _expired: bool = false
var _message: String = "" setget , get_message


func _init(message: String, time: float) -> void:
	_message = message
	_amount_time = time


func _ready() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(_amount_time)
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


func get_message() -> String:
	return _message
