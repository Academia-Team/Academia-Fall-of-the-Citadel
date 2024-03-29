extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_player_pick_up_weapon(weapon_name):
	$weapon_info.add_text(weapon_name)


func _on_player_used_weapon(_weapon_name):
	$weapon_info.clear()
