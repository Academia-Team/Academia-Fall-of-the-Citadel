extends ColorRect

const game_scene = preload("res://scene/gamescr.tscn")

var enter_seed

func _ready():
	$Option.hide()
	$enter_button.grab_focus()
	enter_seed = false

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$perish_button.emit_signal("pressed")

func _on_enter_button_pressed():
	var status = get_tree().change_scene_to(game_scene)
	
	if status != OK:
			printerr("Failed to switch to game.")

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_enter_button_gui_input(event):
	if event.is_action("button_options", true) and not enter_seed:
		enter_seed = true
		$Option.show()
		$Option/option_label.text = "Seed:"
		$Option/option_text.grab_focus()


func _on_option_text_focus_exited():
	enter_seed = false
	$Option/option_label.text = "Option:"
	$Option/option_text.text = ""
	$Option.hide()


func _on_option_text_gui_input(event):
	if event.is_action("ui_accept", true):
		enter_seed = false
		
		if len($Option/option_text.text) == 0:
			$enter_button.grab_focus()
		else:
			enter_seeded_game($Option/option_text.text)
	else:
		$Option/option_text.text += event.as_text()

func enter_seeded_game(seed_str):
	var seed_val = 0
		
	if seed_str.is_valid_integer():
		seed_val = seed_str.to_int()
	else:
		seed_val = hash(seed_str)
		
	var game_instance = game_scene.instance()
	game_instance.seed_val = seed_val
	
	add_child(game_instance)
