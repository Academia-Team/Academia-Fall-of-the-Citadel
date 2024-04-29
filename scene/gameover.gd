extends ColorRect

var info_ref = null

func _init():
	yield(self, "ready")
	$revive_button.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$give_up_button.emit_signal("pressed")

func set_info_src(info_obj):
	info_ref = info_obj

func set_score(score_val):
	$score.text = "Score: %d" % score_val

func set_seed(seed_val):
	$seed.text = "Seed: %d" % seed_val

func _on_gameover_draw():
	if info_ref != null:
		set_score(info_ref.score)

func _on_give_up_button_pressed():
	var status = get_tree().change_scene_to(load("res://scene/menu.tscn"))
	
	if status != OK:
			printerr("Failed to switch to menu.")

func _on_revive_button_pressed():
	var status = get_tree().change_scene_to(load("res://scene/gamescr.tscn"))
	
	if status != OK:
			printerr("Failed to switch to game.")
