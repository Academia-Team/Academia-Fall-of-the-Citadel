extends Control

const CHEAT_COUNT_REQ = 3

var cheat_key_counter = 0
var mode = "Regular"
var seed_val = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	if seed_val == null:
		seed_val = gen_seed()
		print("Seed: %d" % seed_val)

	$InfoBar.set_seed(seed_val)
	$InfoBar.set_mode(mode)
	$GameGrid.start($infobar)


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
	elif Input.is_action_just_pressed("cheat_mode"):
		handle_cheat_toggling()


func handle_cheat_toggling():
	if $CheatInputTimeout.is_stopped():
		$CheatInputTimeout.start()
	cheat_key_counter += 1

	if cheat_key_counter == CHEAT_COUNT_REQ:
		cheat_key_counter = 0
		$InfoBar.toggle_cheats()

		if $InfoBar.is_cheat_enabled():
			$InfoBar.set_timed_status("You are a CHEATER!!!")
		else:
			$InfoBar.set_timed_status("Cheats disabled--for now.")


func gen_seed():
	var gen_seed_val = hash(Time.get_datetime_dict_from_system())

	return gen_seed_val


func _on_GameOver_retry():
	$GameOver.stop()
	$InfoBar.reset()
	$InfoBar.set_seed(gen_seed())
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$GameGrid.restart()


func _on_GameOver_leave():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_GameGrid_game_over():
	$GameGrid.cleanup()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameOver.start($infobar)


func _on_GameScrn_tree_exiting():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_CheatInputTimeout_timeout():
	cheat_key_counter = 0
