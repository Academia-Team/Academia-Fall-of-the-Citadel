extends ColorRect

var info_ref = null

func _init():
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$give_up_button.emit_signal("pressed")

func start(info_obj, seed_val):
	info_ref = info_obj
	_set_seed(seed_val)
	show()
	$revive_button.grab_focus()

func _set_score(score_val):
	$score.text = "Score: %d" % score_val

func _set_seed(seed_val):
	$seed.text = "Seed: %d" % seed_val

func _on_gameover_draw():
	if info_ref != null:
		_set_score(info_ref.score)

func _on_give_up_button_pressed():
	var status = get_tree().change_scene_to(load("res://scene/menu.tscn"))
	
	if status != OK:
			printerr("Failed to switch to menu.")

func _on_revive_button_pressed():
	var status = get_tree().change_scene_to(load("res://scene/gamescr.tscn"))
	
	if status != OK:
			printerr("Failed to switch to game.")
