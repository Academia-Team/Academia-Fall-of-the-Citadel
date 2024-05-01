extends ColorRect

const MAX_INT_LEN = 19

var seed_val = null

func _ready():
	$Buttons/Enter.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$Buttons/Perish.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next") and get_focus_owner() == null:
		$Buttons/Enter.grab_focus()

func _on_Enter_pressed():
	var game_instance = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	game_instance.seed_val = seed_val
	self_modulate.a = 0
	
	call_deferred("add_child", game_instance)
	set_process(false)

func _on_Perish_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_Enter_gui_input(event):
	if event.is_action("button_options", true):
		$SeedDialog.show_modal()
		$SeedDialog/HBoxContainer/Line.grab_focus()
		set_process(false)


func _on_SeedDialog_Line_text_entered(new_text):
	seed_val = 0
	
	if new_text.is_valid_integer() and new_text.length() <= MAX_INT_LEN + int(new_text[0] == '-'):
		seed_val = new_text.to_int()
	else:
		seed_val = hash(new_text)
	
	$SeedDialog.hide()
	$SeedDialog.emit_signal("popup_hide")


func _on_SeedDialog_Line_text_change_rejected(_rejected_substring):
	$SeedDialog/Reject.play()


func _on_SeedDialog_popup_hide():
	$SeedDialog/HBoxContainer/Line.text = ""
	$Buttons/Enter.grab_focus()
	set_process(true)


func _on_Enter_mouse_entered():
	$Buttons/Enter.grab_focus()


func _on_Enter_mouse_exited():
	$Buttons/Enter.release_focus()


func _on_Perish_mouse_entered():
	$Buttons/Perish.grab_focus()


func _on_Perish_mouse_exited():
	$Buttons/Perish.release_focus()

func _on_HelpMe_mouse_entered():
	$Buttons/HelpMe.grab_focus()


func _on_HelpMe_mouse_exited():
	$Buttons/HelpMe.release_focus()


func _on_HelpMe_pressed():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.HELP)
