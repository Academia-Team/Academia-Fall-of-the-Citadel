extends ColorRect

signal leave
signal retry

var info_ref = null

var ignore_mouse_warp = false
var mouse_over = null


func _ready():
	hide()


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$Buttons/GiveUp.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next"):
		if get_focus_owner() == null:
			$Buttons/Arise.grab_focus()

		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

			if mouse_over != null:
				warp_mouse(get_global_mouse_position() - Vector2(0, mouse_over.rect_size.y))
				ignore_mouse_warp = true


func start(info_obj):
	info_ref = info_obj
	_set_seed_text(info_obj.get_seed())
	_set_mode_text(info_obj.get_mode())

	if not info_obj.is_tainted():
		$Tainted.hide()
	show()

	$Buttons/Arise.grab_focus()


func stop():
	info_ref = null
	ignore_mouse_warp = false
	mouse_over = null
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


func _on_GiveUp_pressed():
	emit_signal("leave")


func _on_Arise_pressed():
	emit_signal("retry")


func _on_Arise_mouse_entered():
	mouse_over = $Buttons/Arise
	$Buttons/Arise.grab_focus()


func _on_Arise_mouse_exited():
	mouse_over = null
	$Buttons/Arise.release_focus()


func _on_GiveUp_mouse_entered():
	mouse_over = $Buttons/GiveUp
	$Buttons/GiveUp.grab_focus()


func _on_GiveUp_mouse_exited():
	mouse_over = null
	$Buttons/GiveUp.release_focus()


func _on_GameOver_gui_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		if not ignore_mouse_warp:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ignore_mouse_warp = false
