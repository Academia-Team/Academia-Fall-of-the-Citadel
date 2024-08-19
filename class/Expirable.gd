# Marks any type object as expired after a certain time has elapsed.

class_name Expirable
extends Reference

signal expired

var _expired: bool = false setget , is_expired
var _item setget , get_item


func _init(item, timer: SceneTreeTimer) -> void:
	_item = item
	var connect_status: int = timer.connect("timeout", self, "_on_timeout")
	if connect_status != OK:
		printerr('Unable to wrap object "%s" with Expirable.' % _item)
		expire()


func get_item():
	return _item


func _on_timeout() -> void:
	expire()


func expire() -> void:
	if not _expired:
		_expired = true
		emit_signal("expired")


func is_expired() -> bool:
	return _expired
