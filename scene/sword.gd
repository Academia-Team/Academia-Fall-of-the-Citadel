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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sword_area_entered(body):
	if body.get_class() == "player":
		if not body.has_weapon():
			.hide()
			call_deferred("free")
