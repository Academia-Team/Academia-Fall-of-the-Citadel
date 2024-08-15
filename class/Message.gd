class_name Message
extends Node

var _message: String = "" setget , get_message


func _init(message: String) -> void:
	_message = message


func get_message() -> String:
	return _message
