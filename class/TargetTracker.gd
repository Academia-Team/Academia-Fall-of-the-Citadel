class_name TargetTracker
extends Area2D

var _targets: Dictionary = {
	Direction.NORTH: [],
	Direction.SOUTH: [],
	Direction.WEST: [],
	Direction.EAST: [],
	Direction.NORTHEAST: [],
	Direction.NORTHWEST: [],
	Direction.SOUTHEAST: [],
	Direction.SOUTHWEST: []
}


func _ready() -> void:
	set_deferred("monitorable", false)

	var shape_enter_status: int = connect("area_shape_entered", self, "_on_area_shape_entered")
	var shape_exit_status: int = connect("area_shape_exited", self, "_on_area_shape_exited")

	if not (shape_enter_status == OK or shape_exit_status == OK):
		printerr("Internal TargetTracker Failure.")


func disable() -> void:
	set_deferred("monitoring", false)
	call_deferred("clear")


func enable() -> void:
	set_deferred("monitoring", true)


func clear() -> void:
	for key in _targets:
		_targets[key] = []


func get_targets(orient: int) -> Array:
	if orient in _targets:
		return _targets[orient].duplicate(true)

	printerr("Orientation %d is invalid for targetting." % orient)
	return []


func _on_area_shape_entered(
	_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int
) -> void:
	var triggered_collisionbox: CollisionShape2D = shape_owner_get_owner(local_shape_index)

	if triggered_collisionbox is Detector:
		_targets[triggered_collisionbox.orientation].append(area)


func _on_area_shape_exited(
	_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int
) -> void:
	var triggered_collisionbox: CollisionShape2D = shape_owner_get_owner(local_shape_index)

	if triggered_collisionbox is Detector:
		_targets[triggered_collisionbox.orientation].erase(area)
