extends Area2D
class_name enemy

const direction = preload("res://class/direction.gd")

signal enemy_destroyed(enemy_type)

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "zombie")
	
	hide()
	$collisionbox.set_deferred("monitoring", false)
	$collisionbox.set_deferred("monitorable", false)

func attack():
	$collisionbox.set_deferred("monitoring", false)
	$collisionbox.set_deferred("monitorable", false)
	emit_signal("enemy_destroyed", get_meta("type"))
	$CharacterSprite.show_hurt()

func spawn(pos, orient):
	position = pos
	$CharacterSprite.set_orient(orient)
	
	show()
	$collisionbox.set_deferred("monitoring", true)
	$collisionbox.set_deferred("monitorable", true)
