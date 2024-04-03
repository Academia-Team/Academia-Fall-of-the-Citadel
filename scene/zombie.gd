extends Area2D
class_name enemy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_zombie_area_entered(body):
	.hide()
	call_deferred("free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
