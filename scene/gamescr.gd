extends Control

var seed_val = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if seed_val == null:
		seed_val = gen_seed()
		print("Seed: %d" % seed_val)

	$infobar.set_seed(seed_val)
	$gamegrid.start($infobar)

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)

func gen_seed():
	var gen_seed_val = hash(Time.get_datetime_dict_from_system())
	
	return gen_seed_val

func _on_gameover_retry():
	$gameover.stop()
	$infobar.reset()
	$infobar.set_seed(gen_seed())
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$gamegrid.restart()

func _on_gameover_leave():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_gamegrid_game_over():
	$gamegrid.cleanup()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$gameover.start($infobar)


func _on_gamescr_tree_exiting():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
