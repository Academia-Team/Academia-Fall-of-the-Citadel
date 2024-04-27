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
	$CharacterSprite.show_hurt()
