extends Area2D
class_name enemy

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "sword")

func attack():
	.hide()
	call_deferred("free")
