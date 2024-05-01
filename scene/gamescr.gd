extends Control

var seed_val = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if seed_val == null:
		seed_val = gen_seed()
	
		if OS.is_debug_build():
			print("Seed: %d" % seed_val)

	$infobar.set_seed(seed_val)
	$gamegrid.start($infobar, seed_val)

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)

func gen_seed():
	var gen_seed_val = hash(Time.get_datetime_dict_from_system())
	
	return gen_seed_val

func _on_gameover_retry():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.GAME)

func _on_gameover_leave():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_gamegrid_game_over():
	call_deferred("remove_child", $gamegrid)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$gameover.start($infobar)
