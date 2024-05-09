extends Area2D
class_name item

func get_class():
	return "item"


func _ready():
	set_meta("type", "sword")

func acquire():
	.hide()
	$collisionbox.set_deferred("disabled", true)
	$acquire_sfx.play()
	return get_meta("type")

func exists():
	return visible

func shove_to(pos):
	position = pos

func is_shovable():
	return true

func _on_acquire_sfx_finished():
	queue_free()
