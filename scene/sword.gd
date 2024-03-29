extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sword_area_entered(body):
	if body.has_method("has_weapon"):
		if not body.has_weapon():
			.hide()
			call_deferred("free")
