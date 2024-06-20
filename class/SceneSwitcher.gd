extends Reference
class_name SceneSwitcher

enum { MENU, GAME, HELP, CREDIT, INTRO, QUIT }


static func get_scene(sceneID):
	match sceneID:
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


static func change_scene_tree_to(tree, sceneID):
	if tree.change_scene_to(get_scene(sceneID)) != OK:
		printerr("Failed to switch to %s" % scene_to_str(sceneID))


static func scene_to_str(sceneID):
	match sceneID:
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
