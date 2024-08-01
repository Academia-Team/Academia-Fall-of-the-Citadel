extends ColorRect

var seed_val: int = 0
var seed_val_set: bool = false


func _ready() -> void:
	($Version as Label).text = get_version_str()

	if OS.get_name() == "HTML5":
		var options_container: TabContainer = $Options
		for index in options_container.get_tab_count:
			var buttons: ButtonGridContainer = options_container.get_tab_control(index)
			if not buttons.hide_and_disable("Perish"):
				print("Button 'Perish' not found in tab %d" % index)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var options_container: TabContainer = $Options

		if not _get_button_grid().are_buttons_disabled():
			var previous_tab: int = options_container.get_current_tab() - 1

			if previous_tab >= 0:
				options_container.set_current_tab(previous_tab)


func get_version_str() -> String:
	var version_str = ProjectSettings.get_setting("global/Version")

	if ProjectSettings.get_setting("global/Dev"):
		version_str += "-dev"

	return version_str


func _on_Enter_button_effects_finished() -> void:
	_get_button_grid().disable_buttons()
	($Options as TabContainer).set_current_tab(($Options/ModeButtons as Node).get_index())


func _get_button_grid() -> ButtonGridContainer:
	return ($Options as TabContainer).get_current_tab_control() as ButtonGridContainer


func _activate_game(mode: String) -> void:
	_get_button_grid().disable_buttons()

	var game_instance: Control = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	if seed_val_set:
		game_instance.seed_val = seed_val

	game_instance.mode = mode

	call_deferred("add_child", game_instance)


func _on_Perish_button_effects_finished() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_Enter_button_input(event: InputEvent) -> void:
	if event.is_action("button_options", true):
		_get_button_grid().disable_buttons()
		($SeedDialog as LineDialog).prompt_integer("Seed:")


func _on_HelpMe_button_effects_finished() -> void:
	_get_button_grid().disable_buttons()
	($Instructions as Book).start()


func _on_Credit_button_effects_finished() -> void:
	_get_button_grid().disable_buttons()
	($Credits as CanvasItem).visible = true
	($Credits as Credits).start()


func _on_Regular_button_effects_finished() -> void:
	_activate_game("Regular")


func _on_Duck_button_effects_finished() -> void:
	_activate_game("Duck")


func _on_SeedDialog_text_rejected() -> void:
	($Alert as AnimationPlayer).play()


func _on_SeedDialog_integer_prompt_finished(text_entered: bool, value: int) -> void:
	if text_entered:
		seed_val = value
		seed_val_set = true

	# Delay the re-enabling of buttons to ensure that they don't accidently activate.
	_get_button_grid().call_deferred("enable_buttons")


func _on_Instructions_finished() -> void:
	($Instructions as Book).stop()
	_get_button_grid().enable_buttons()


func _on_Credits_done() -> void:
	($Credits as Credits).stop()
	($Credits as CanvasItem).hide()

	var buttons: ButtonGridContainer = _get_button_grid()
	buttons.enable_buttons()
	(buttons as FocusedGridContainer).force_focus()


func _on_Options_tab_changed(_tab: int) -> void:
	_get_button_grid().enable_buttons()
