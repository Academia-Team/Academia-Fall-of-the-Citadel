extends Reference
class_name SceneSwitcher

enum { MENU, GAME, HELP, CREDIT, INTRO, QUIT }


static func get_scene(scene_ID):
	match scene_ID:
		MENU:
			return load("res://scene/menu.tscn")
		GAME:
			return load("res://scene/gamescr.tscn")
		HELP:
			return load("res://scene/instructions.tscn")
		CREDIT:
			return load("res://scene/credit.tscn")
		INTRO:
			return load("res://scene/intro.tscn")
		QUIT:
			return load("res://scene/end.tscn")
		_:
			return null


static func change_scene_tree_to(tree, scene_ID):
	if tree.change_scene_to(get_scene(scene_ID)) != OK:
		printerr("Failed to switch to %s" % scene_to_str(scene_ID))


static func scene_to_str(scene_ID):
	match scene_ID:
		MENU:
			return "menu"
		GAME:
			return "game"
		HELP:
			return "help"
		CREDIT:
			return "credit"
		INTRO:
			return "intro"
		QUIT:
			return "quit"
		_:
			return "invalid"
