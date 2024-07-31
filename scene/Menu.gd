extends ColorRect

var seed_val = null


func _ready():
	$Buttons/Enter.grab_silent_focus()
	$Version.text = get_version_str()


func get_version_str():
	var version_str = ProjectSettings.get_setting("global/Version")

	if ProjectSettings.get_setting("global/Dev"):
		version_str += "-dev"

	return version_str


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


func _on_Enter_button_effects_finished():
	_disable_menu_buttons()
	$Buttons.hide()
	$ModeDialog.show_modal()
	$ModeDialog/Buttons/Regular.grab_silent_focus()


func _activate_game(mode):
	$ModeDialog.hide()
	_disable_menu_buttons()

	var game_instance = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	game_instance.seed_val = seed_val
	game_instance.mode = mode
	self_modulate.a = 0

	call_deferred("add_child", game_instance)
	$Buttons/Enter.release_focus()


func _on_Perish_button_effects_finished():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.QUIT)


func _on_Enter_gui_input(event):
	if not $Buttons/Enter.disabled and event.is_action("button_options", true):
		($SeedDialog as LineDialog).prompt_integer("Seed:")


func _on_HelpMe_button_effects_finished():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.HELP)


func _on_Credit_button_effects_finished():
	SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.CREDIT)


func _on_ModeDialog_hide():
	_enable_menu_buttons()
	$Buttons/Enter.grab_silent_focus()
	$Buttons.show()


func _on_Regular_button_effects_finished():
	_activate_game("Regular")


func _on_Duck_button_effects_finished():
	_activate_game("Duck")


func _on_SeedDialog_text_rejected():
	($Alert as AnimationPlayer).play()


func _on_SeedDialog_integer_prompt_finished(text_entered: bool, value: int):
	if text_entered:
		seed_val = value
	$Buttons/Enter.grab_silent_focus()
