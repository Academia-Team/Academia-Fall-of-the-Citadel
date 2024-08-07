class_name Menu
extends ColorRect

const MAIN_BTN_IDX: int = 0
const MODE_BTN_IDX: int = 1

var _menu_enabled: bool = false
var _seed_val: int = 0
var _seed_val_set: bool = false


func _ready() -> void:
	hide()

	($VBoxContainer/Info/Dev as CanvasItem).visible = ProjectSettings.get_setting("global/Dev")

	var options_container: TabContainer = $VBoxContainer/Options
	for index in options_container.get_tab_count():
		var buttons: ButtonGridContainer = options_container.get_tab_control(index)

		if OS.get_name() == "HTML5":
			var disable_success: bool = buttons.hide_and_disable("Perish")
			if not disable_success:
				print("Button 'Perish' not found in tab %d" % index)


func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	_seed_val_set = false
	_menu_enabled = true

	var options_container: TabContainer = $VBoxContainer/Options
	var buttons: ButtonGridContainer = options_container.get_tab_control(0)
	buttons.enable_buttons()
	options_container.set_current_tab(0)


func _disable() -> void:
	_menu_enabled = false
	_get_button_grid().disable_buttons()


func _process(_delta: float) -> void:
	if _menu_enabled and Input.is_action_just_pressed("ui_cancel"):
		var options_container: TabContainer = $VBoxContainer/Options

		if not _get_button_grid().are_buttons_disabled():
			var previous_tab: int = options_container.get_current_tab() - 1

			if previous_tab >= 0:
				options_container.set_current_tab(previous_tab)


func _on_Enter_button_effects_finished() -> void:
	_get_button_grid().disable_buttons()
	($VBoxContainer/Options as TabContainer).set_current_tab(MODE_BTN_IDX)


func _get_button_grid() -> ButtonGridContainer:
	return ($VBoxContainer/Options as TabContainer).get_current_tab_control() as ButtonGridContainer


func _activate_game(mode: String) -> void:
	_disable()

	if _seed_val_set:
		($Game as Game).play(mode, _seed_val)
	else:
		($Game as Game).play(mode)


func _on_Perish_button_effects_finished() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_Enter_button_input(event: InputEvent) -> void:
	if event.is_action("button_options", true):
		_disable()
		($SeedDialog as LineDialog).prompt_integer("Seed:")


func _on_HelpMe_button_effects_finished() -> void:
	_disable()
	($Instructions as Book).start()


func _on_Credit_button_effects_finished() -> void:
	_disable()
	($Credits as Credits).start()


func _on_Regular_button_effects_finished() -> void:
	_activate_game("Regular")


func _on_Duck_button_effects_finished() -> void:
	_activate_game("Duck")


func _on_SeedDialog_text_rejected() -> void:
	($Alert as AnimationPlayer).play()


func _on_SeedDialog_integer_prompt_finished(text_entered: bool, value: int) -> void:
	if text_entered:
		_seed_val = value
		_seed_val_set = true

	# Delay the re-enabling of the menu to ensure that buttons don't accidently activate.
	call_deferred("enable")


func _on_Instructions_finished() -> void:
	($Instructions as Book).stop()
	enable()


func _on_Credits_done() -> void:
	($Credits as Credits).stop()
	($Credits as CanvasItem).hide()
	enable()
	_get_button_grid().force_focus()


func _on_Options_tab_changed(_tab: int) -> void:
	_get_button_grid().enable_buttons()
