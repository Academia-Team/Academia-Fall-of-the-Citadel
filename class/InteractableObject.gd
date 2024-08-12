class_name InteractableObject
extends Area2D

signal existence_changed(value)

export var points: int = 0

var exists: bool = false setget set_existence, get_existence


func set_existence(value: bool) -> void:
	exists = value
	set_visible(exists)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not exists)
		elif child is TargetTracker:
			if exists:
				child.enable()
			else:
				child.disable()
	emit_signal("existence_changed", value)


func get_existence() -> bool:
	return exists
