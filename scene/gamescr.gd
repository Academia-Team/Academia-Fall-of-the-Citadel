extends Control

var seed_val

func _ready():
	seed_val = gen_seed()
	
	if OS.is_debug_build():
		print("Seed: %d" % seed_val)

	$gamegrid.start($infobar, seed_val)

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		var status = get_tree().change_scene_to(load("res://scene/menu.tscn"))
		
		if status != OK:
			printerr("Failed to switch to menu.")

func gen_seed():
	var gen_seed_val = hash(Time.get_datetime_dict_from_system())
	
	return gen_seed_val
