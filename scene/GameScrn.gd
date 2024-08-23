class_name Game
extends Control

const CHEAT_COUNT_REQ := 3

var _cheat_key_counter := 0
var _playing := false


func _ready() -> void:
	hide()


func play(mode: String, seed_val: int = gen_seed()) -> void:
	_stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	show()
	_playing = true

	$InfoBar.set_seed(seed_val)
	$InfoBar.set_mode(mode)
	$GameGrid.start($InfoBar)
	$Audio.play()


func _stop() -> void:
	$GameGrid.cleanup()
	$GameOver.stop()
	$GameGrid.stop()
	$InfoBar.reset()
	$Audio.reset()
	hide()
	_playing = false


func _quit() -> void:
	_stop()
	get_parent().call_deferred("enable")


func _process(_delta: float) -> void:
	if _playing:
		if Input.is_action_just_pressed("quit"):
			_quit()
		elif Input.is_action_just_pressed("cheat_mode"):
			handle_cheat_toggling()


func handle_cheat_toggling() -> void:
	if $CheatInputTimeout.is_stopped():
		$CheatInputTimeout.start()
	_cheat_key_counter += 1

	if _cheat_key_counter == CHEAT_COUNT_REQ:
		_cheat_key_counter = 0
		$InfoBar.toggle_cheats()

		if $InfoBar.is_cheat_enabled():
			$InfoBar.set_timed_status("You are a CHEATER!!!")
		else:
			$InfoBar.set_timed_status("Cheats disabled--for now.")


func gen_seed() -> int:
	return hash(Time.get_datetime_dict_from_system())


func _on_GameOver_retry(mode, seed_val: int = gen_seed()) -> void:
	play(mode, seed_val)


func _on_GameOver_leave() -> void:
	_quit()


func _on_GameGrid_game_over() -> void:
	$Audio.reset()
	$GameGrid.cleanup()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameOver.start($InfoBar)
	_playing = false


func _on_CheatInputTimeout_timeout() -> void:
	_cheat_key_counter = 0


func _on_GameGrid_message_change_request(text: String, duration: float):
	if duration == TileWorld.EVENT_NO_LIMIT:
		$InfoBar.set_status(text)
	else:
		$InfoBar.set_timed_status(text, duration)


func _on_GameGrid_music_change_request(stream: AudioStream):
	$Audio.push(stream)
