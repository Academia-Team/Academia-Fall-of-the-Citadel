class_name Game
extends Control

const CHEAT_COUNT_REQ: int = 3

var cheat_key_counter: int = 0


func _ready() -> void:
	hide()


func play(mode: String, seed_val: int = gen_seed()) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	show()

	$InfoBar.set_seed(seed_val)
	$InfoBar.set_mode(mode)
	$GameGrid.start($InfoBar)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
	elif Input.is_action_just_pressed("cheat_mode"):
		handle_cheat_toggling()


func handle_cheat_toggling() -> void:
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


func gen_seed() -> int:
	return hash(Time.get_datetime_dict_from_system())


func _on_GameOver_retry(seed_val: int = gen_seed()) -> void:
	$GameOver.stop()
	$InfoBar.reset()
	$InfoBar.set_seed(seed_val)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$GameGrid.restart()


func _on_GameOver_leave() -> void:
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_GameGrid_game_over() -> void:
	$GameGrid.cleanup()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameOver.start($InfoBar)


func _on_GameScrn_tree_exiting() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_CheatInputTimeout_timeout() -> void:
	cheat_key_counter = 0
