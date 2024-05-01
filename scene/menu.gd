extends ColorRect

const MAX_INT_LEN = 19

var game_playing = false
var seed_val = null

func _ready():
	$Option.hide()
	$enter_button.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("quit") and not game_playing:
		$perish_button.emit_signal("pressed")
	elif Input.is_action_just_pressed("ui_focus_next") and get_focus_owner() == null:
		$enter_button.grab_focus()

func _on_enter_button_pressed():
	var game_instance = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	game_instance.seed_val = seed_val
	self_modulate.a = 0
	
	call_deferred("add_child", game_instance)
	game_playing = true

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_enter_button_gui_input(event):
	if event.is_action("button_options", true):
		$Option.show()
		$Option/option_label.text = "Seed:"
		$Option/option_line.grab_focus()


func _on_option_line_focus_exited():
	$Option/option_line.text = ""
	$Option/option_label.text = "Option:"
	$Option.hide()
	$enter_button.grab_focus()

func _on_option_line_text_entered(new_text):
	seed_val = 0
	
	if new_text.is_valid_integer() and new_text.length() <= MAX_INT_LEN + int(new_text[0] == '-'):
		seed_val = new_text.to_int()
	else:
		seed_val = hash(new_text)
	
	$Option/option_line.release_focus()


func _on_option_line_gui_input(event):
	if event.is_action("ui_cancel", true):
		$enter_button.grab_focus()


func _on_option_line_text_change_rejected(_rejected_substring):
	$Option/reject.play()


func _on_enter_button_mouse_entered():
	$enter_button.grab_focus()


func _on_enter_button_mouse_exited():
	$enter_button.release_focus()


func _on_perish_button_mouse_entered():
	$perish_button.grab_focus()


func _on_perish_button_mouse_exited():
	$perish_button.release_focus()

func _on_help_me_button_mouse_entered():
	$help_me_button.grab_focus()


func _on_help_me_button_mouse_exited():
	$help_me_button.release_focus()


func _on_help_me_button_pressed():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.HELP)
