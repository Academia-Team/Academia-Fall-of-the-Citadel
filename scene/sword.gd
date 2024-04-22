extends Area2D
class_name weapon

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_class():
	return "weapon"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "sword")

func acquire():
	.hide()
	call_deferred("free")
	return get_class()
