extends Area2D
class_name enemy

const direction = preload("res://class/direction.gd")

var cur_orient

signal enemy_destroyed(enemy_type)

func get_class():
	cur_orient = direction.SOUTH
	
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "zombie")

func attack():
	$collisionbox.set_deferred("monitoring", false)
	$collisionbox.set_deferred("monitorable", false)
	emit_signal("enemy_destroyed", get_meta("type"))
	$Sprite.self_modulate = Color.tomato

func set_orient(orient):
	orient = direction.get_horz_component(orient)
	match orient:
		direction.NORTH:
			$Sprite.set_texture(load("res://asset/Zombie_NORTH.png"))
		direction.SOUTH:
			$Sprite.set_texture(load("res://asset/Zombie_SOUTH.png"))
		_:
			$Sprite.set_texture(load("res://asset/Zombie_SIDE.png"))
			
	$Sprite.flip_h = (orient == direction.WEST)
	cur_orient = orient
