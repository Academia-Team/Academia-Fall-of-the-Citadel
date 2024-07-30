extends ColorRect

signal leave
signal retry

var info_ref = null


func _ready():
	hide()


func start(info_obj):
	info_ref = info_obj
	_set_seed_text(info_obj.get_seed())
	_set_mode_text(info_obj.get_mode())

	if not info_obj.is_tainted():
		$Tainted.hide()
	show()

	$Buttons/Arise.grab_silent_focus()


func stop():
	info_ref = null
	release_focus()
	hide()


func _set_seed_text(seed_val):
	if seed_val != null:
		$Seed.text = "Seed: %d" % seed_val


func _set_mode_text(mode):
	if mode != null:
		$Mode.text = "Mode: %s" % mode


func _on_GameOver_draw():
	if info_ref != null:
		$Score.text = "Score: %d" % info_ref.get_score()


func _on_GiveUp_button_effects_finished():
	emit_signal("leave")


func _on_Arise_button_effects_finished():
	emit_signal("retry")
