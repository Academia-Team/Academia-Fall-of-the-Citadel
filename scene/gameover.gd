extends ColorRect

var info_ref = null

signal leave()
signal retry()

func _ready():
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$give_up_button.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next") and get_focus_owner() == null:
		$enter_button.grab_focus()

func start(info_obj, seed_val):
	info_ref = info_obj
	_set_seed(seed_val)
	show()
	$revive_button.grab_focus()

func _set_score(score_val):
	if score_val != null:
		$score.text = "Score: %d" % score_val

func _set_seed(seed_val):
	if seed_val != null:
		$seed.text = "Seed: %d" % seed_val

func _on_gameover_draw():
	if info_ref != null:
		_set_score(info_ref.score)

func _on_give_up_button_pressed():
	emit_signal("leave")

func _on_revive_button_pressed():
	emit_signal("retry")

func _on_revive_button_mouse_entered():
	$revive_button.grab_focus()


func _on_revive_button_mouse_exited():
	$revive_button.release_focus()


func _on_give_up_button_mouse_entered():
	$give_up_button.grab_focus()


func _on_give_up_button_mouse_exited():
	$give_up_button.release_focus()
