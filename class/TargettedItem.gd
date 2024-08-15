tool
class_name TargettedItem
extends Item

var targets: Array = [] setget set_targets, get_targets


func set_targets(value: Array) -> void:
	targets = value


func get_targets() -> Array:
	return targets
