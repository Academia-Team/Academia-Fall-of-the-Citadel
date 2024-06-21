extends ColorRect


func _ready():
	if OS.get_name() != "HTML5":
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.INTRO)


func _process(_delta):
	if Input.is_action_pressed("ui_advance"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.INTRO)
