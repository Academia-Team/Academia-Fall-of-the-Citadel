extends Control

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to(load("res://scene/menu.tscn"))
