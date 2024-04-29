extends Control

func _ready():
	$gamegrid.start()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		var status = get_tree().change_scene_to(load("res://scene/menu.tscn"))
		
		if status != OK:
			printerr("Failed to switch to menu.")
