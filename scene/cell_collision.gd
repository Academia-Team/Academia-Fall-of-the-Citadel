extends Area2D

var area_ref

func _ready():
	area_ref = null
	$CollisionShape2D.set_deferred("disabled", true)

func set_pos(pos):
	pos.x += 16
	pos.y += 16
	position = pos
	$CollisionShape2D.disabled = false

func _on_cell_collision_area_entered(area):
	area_ref = area

func _on_cell_collision_area_exited(area):
	area_ref = null

func obj_found():
	return area_ref != null

func get_obj_ref():
	return area_ref
