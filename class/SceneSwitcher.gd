class_name SceneSwitcher
extends Reference

enum { MENU, GAME, INTRO, QUIT }


static func get_scene(scene_id):
	match scene_id:
		MENU:
			return load("res://scene/Menu.tscn")
		GAME:
			return load("res://scene/GameScrn.tscn")
		INTRO:
			return load("res://scene/Intro.tscn")
		QUIT:
			return load("res://scene/End.tscn")
		_:
			return null


static func change_scene_tree_to(tree, scene_id):
	if tree.change_scene_to(get_scene(scene_id)) != OK:
		printerr("Failed to switch to %s" % scene_to_str(scene_id))


static func scene_to_str(scene_id):
	match scene_id:
		MENU:
			return "menu"
		GAME:
			return "game"
		INTRO:
			return "intro"
		QUIT:
			return "quit"
		_:
			return "invalid"
