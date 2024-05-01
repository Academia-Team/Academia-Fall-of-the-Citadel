extends ColorRect

var info_ref = null

signal leave()
signal retry()

func _ready():
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$Buttons/GiveUp.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next") and get_focus_owner() == null:
		$Buttons/Arise.grab_focus()

func start(info_obj):
	info_ref = info_obj
	_set_seed_text(info_obj.get_seed())
	show()
	$Buttons/Arise.grab_focus()

func _set_seed_text(seed_val):
	if seed_val != null:
		$Seed.text = "Seed: %d" % seed_val

func _on_gameover_draw():
	if info_ref != null:
		$Score.text = info_ref.get_score_text()

func _on_GiveUp_pressed():
	emit_signal("leave")

func _on_Arise_pressed():
	emit_signal("retry")

func _on_Arise_mouse_entered():
	$Buttons/Arise.grab_focus()


func _on_Arise_mouse_exited():
	$Buttons/Arise.release_focus()


func _on_GiveUp_mouse_entered():
	$Buttons/GiveUp.grab_focus()


func _on_GiveUp_mouse_exited():
	$Buttons/GiveUp.release_focus()
