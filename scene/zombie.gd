extends Area2D
class_name enemy

signal enemy_destroyed(enemy_type)

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "zombie")

func attack():
	.hide()
	call_deferred("free")
	emit_signal("enemy_destroyed", get_meta("type"))
