extends Area2D
class_name item

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_class():
	return "item"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "sword")

func acquire():
	.hide()
	$collisionbox.set_deferred("disabled", true)
	$acquire_sfx.play()
	return get_meta("type")


func _on_acquire_sfx_finished():
	queue_free()
