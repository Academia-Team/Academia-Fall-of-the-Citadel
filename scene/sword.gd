extends Area2D
class_name item

var _h_shove_dir = Direction.WEST
var _v_shove_dir = Direction.NORTH

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

func get_h_shove_pos():
	return Direction.translate_pos(position, _h_shove_dir, 32)

func get_v_shove_pos():
	return Direction.translate_pos(position, _v_shove_dir, 32)

func h_shove_blocked():
	_h_shove_dir = Direction.get_opposing_dirs(_h_shove_dir)[0]

func v_shove_blocked():
	_v_shove_dir = Direction.get_opposing_dirs(_v_shove_dir)[0]

func shove_to(pos):
	position = pos

func is_shovable():
	return true

func _on_acquire_sfx_finished():
	queue_free()
