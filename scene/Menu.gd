extends ColorRect

const MAX_INT_LEN = 19

var ignore_mouse_warp = false
var mouse_over = null
var seed_val = null


func _ready():
	$Buttons/Enter.grab_focus()
	$Version.text = get_version_str()


func get_version_str():
	var version_str = ProjectSettings.get_setting("global/Version")

	if ProjectSettings.get_setting("global/Dev"):
		version_str += "-dev"

	return version_str


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$Buttons/Perish.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next"):
		if get_focus_owner() == null:
			$Buttons/Enter.grab_focus()

		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

			if mouse_over != null:
				warp_mouse(get_global_mouse_position() - Vector2(0, mouse_over.rect_size.y))
				ignore_mouse_warp = true


func _disable_menu_buttons():
	$Buttons/Enter.disabled = true
	$Buttons/HelpMe.disabled = true
	$Buttons/Credit.disabled = true
	$Buttons/Perish.disabled = true


func _enable_menu_buttons():
	$Buttons/Enter.disabled = false
	$Buttons/HelpMe.disabled = false
	$Buttons/Credit.disabled = false
	$Buttons/Perish.disabled = false


func _on_Enter_pressed():
	_disable_menu_buttons()
	$Buttons.hide()
	$ModeDialog.show_modal()
	$ModeDialog/Buttons/Regular.grab_focus()


func _activate_game(mode):
	$ModeDialog.hide()
	_disable_menu_buttons()

	var game_instance = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	game_instance.seed_val = seed_val
	game_instance.mode = mode
	self_modulate.a = 0

	call_deferred("add_child", game_instance)
	set_process(false)
	$Buttons/Enter.release_focus()


func _on_Perish_pressed():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.QUIT)


func _on_Enter_gui_input(event):
	if not $Buttons/Enter.disabled and event.is_action("button_options", true):
		$SeedDialog.show_modal()
		$SeedDialog/HBoxContainer/Line.grab_focus()
		set_process(false)


func _on_SeedDialog_Line_text_entered(new_text):
	seed_val = 0

	if new_text.is_valid_integer() and new_text.length() <= MAX_INT_LEN + int(new_text[0] == "-"):
		seed_val = new_text.to_int()
	else:
		seed_val = hash(new_text)

	$SeedDialog.hide()
	$SeedDialog.emit_signal("popup_hide")


func _on_SeedDialog_Line_text_change_rejected(_rejected_substring):
	$SeedDialog/Reject.play()


func _on_SeedDialog_hide():
	$SeedDialog/HBoxContainer/Line.text = ""
	$Buttons/Enter.grab_focus()
	set_process(true)
	_enable_menu_buttons()


func _on_Enter_mouse_entered():
	mouse_over = $Buttons/Enter
	$Buttons/Enter.grab_focus()


func _on_Enter_mouse_exited():
	mouse_over = null
	$Buttons/Enter.release_focus()


func _on_Perish_mouse_entered():
	mouse_over = $Buttons/Perish
	$Buttons/Perish.grab_focus()


func _on_Perish_mouse_exited():
	mouse_over = null
	$Buttons/Perish.release_focus()


func _on_HelpMe_mouse_entered():
	mouse_over = $Buttons/HelpMe
	$Buttons/HelpMe.grab_focus()


func _on_HelpMe_mouse_exited():
	mouse_over = null
	$Buttons/HelpMe.release_focus()


func _on_HelpMe_pressed():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.HELP)


func _on_Menu_gui_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		if not ignore_mouse_warp:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ignore_mouse_warp = false


func _on_Credit_pressed():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.CREDIT)


func _on_Credit_mouse_entered():
	mouse_over = $Buttons/Credit
	$Buttons/Credit.grab_focus()


func _on_Credit_mouse_exited():
	mouse_over = null
	$Buttons/Credit.release_focus()


func _on_ModeDialog_hide():
	ignore_mouse_warp = false
	mouse_over = null

	_enable_menu_buttons()
	$Buttons/Enter.grab_focus()
	$Buttons.show()


func _on_Regular_pressed():
	_activate_game("Regular")


func _on_Duck_pressed():
	_activate_game("Duck")


func _on_ModeDialog_about_to_show():
	ignore_mouse_warp = false
	mouse_over = null


func _on_Regular_mouse_entered():
	mouse_over = $ModeDialog/Buttons/Regular
	$ModeDialog/Buttons/Regular.grab_focus()


func _on_Regular_mouse_exited():
	mouse_over = null
	$ModeDialog/Buttons/Regular.release_focus()


func _on_Duck_mouse_entered():
	mouse_over = $ModeDialog/Buttons/Duck
	$ModeDialog/Buttons/Duck.grab_focus()


func _on_Duck_mouse_exited():
	mouse_over = null
	$ModeDialog/Buttons/Duck.release_focus()
