extends Area2D

var area_ref_list = Array()
var ready_for_collisions

signal checked_for_collisions

func _ready():
	area_ref_list = null
	ready_for_collisions = false
	$CollisionShape2D.set_deferred("disabled", true)
	
func _process(delta):
	if not $CollisionShape2D.disabled:
		if ready_for_collisions:
			area_ref_list = get_overlapping_areas()
			emit_signal("checked_for_collisions")
		ready_for_collisions = true

func set_pos(pos):
	pos.x += 16
	pos.y += 16
	position = pos
	$CollisionShape2D.disabled = false

func _on_cell_collision_area_entered(area):
	area_ref_list = get_overlapping_areas()

func _on_cell_collision_area_exited(area):
	area_ref_list = get_overlapping_areas()

func obj_found():
	return area_ref_list.size() > 0

func get_obj_refs():
	return get_overlapping_areas()
