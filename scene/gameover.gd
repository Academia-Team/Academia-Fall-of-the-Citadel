extends ColorRect

var info_ref
var score

func _init():
	info_ref = null
	yield(self, "ready")
	$revive_button.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$give_up_button.emit_signal("pressed")

func set_info_src(info_obj):
	info_ref = info_obj

func set_score(score_val):
	$score.text = "Score: %d" % score_val

func _on_gameover_draw():
	if info_ref != null:
		set_score(info_ref.score)

func _on_give_up_button_pressed():
	get_tree().change_scene_to(load("res://scene/menu.tscn"))
