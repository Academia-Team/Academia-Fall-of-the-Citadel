extends ColorRect

var seed_val: int = 0
var seed_val_set: bool = false


func _ready() -> void:
	($Version as Label).text = get_version_str()

	if OS.get_name() == "HTML5":
		($Buttons as ButtonGridContainer).hide_and_disable("Perish")
		($ModeDialog/Buttons as ButtonGridContainer).hide_and_disable("Perish")


func get_version_str() -> String:
	var version_str = ProjectSettings.get_setting("global/Version")

	if ProjectSettings.get_setting("global/Dev"):
		version_str += "-dev"

	return version_str


func _on_Enter_button_effects_finished() -> void:
	($Buttons as ButtonGridContainer).disable_buttons()
	($Buttons as CanvasItem).hide()
	($ModeDialog as Control).show_modal()


func _activate_game(mode: String) -> void:
	($ModeDialog as CanvasItem).hide()
	($Buttons as ButtonGridContainer).disable_buttons()

	var game_instance: Control = SceneSwitcher.get_scene(SceneSwitcher.GAME).instance()
	if seed_val_set:
		game_instance.seed_val = seed_val

	game_instance.mode = mode
	self_modulate.a = 0

	call_deferred("add_child", game_instance)


func _on_Perish_button_effects_finished() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_Enter_gui_input(event: InputEvent) -> void:
	if not ($Buttons/Enter as BaseButton).disabled and event.is_action("button_options", true):
		($Buttons as ButtonGridContainer).disable_buttons()
		($SeedDialog as LineDialog).prompt_integer("Seed:")


func _on_HelpMe_button_effects_finished() -> void:
	($Buttons as ButtonGridContainer).disable_buttons()
	($Instructions as Book).start()


func _on_Credit_button_effects_finished() -> void:
	($Buttons as ButtonGridContainer).disable_buttons()
	($Credits as CanvasItem).visible = true
	($Credits as Credits).start()


func _on_ModeDialog_hide() -> void:
	($Buttons as ButtonGridContainer).enable_buttons()
	($Buttons as CanvasItem).show()


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
	($Buttons as ButtonGridContainer).call_deferred("enable_buttons")


func _on_Instructions_finished() -> void:
	($Instructions as Book).stop()
	($Buttons as ButtonGridContainer).enable_buttons()


func _on_Credits_done() -> void:
	($Credits as Credits).stop()
	($Credits as CanvasItem).hide()
	($Buttons as ButtonGridContainer).enable_buttons()
