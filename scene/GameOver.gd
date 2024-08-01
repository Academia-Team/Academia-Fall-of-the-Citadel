class_name GameOver
extends ColorRect

signal leave
signal retry(seed_val)

var info_ref: InfoBar = null
var new_seed_val: int = 0
var new_seed_val_set: bool = false


func _ready() -> void:
	hide()
	($Buttons as ButtonGridContainer).disable_buttons()


func start(info_obj: InfoBar) -> void:
	info_ref = info_obj
	_set_seed_text(info_obj.get_seed())
	_set_mode_text(info_obj.get_mode())

	if not info_obj.is_tainted():
		$Tainted.hide()

	($Buttons as ButtonGridContainer).enable_buttons()
	show()


func stop() -> void:
	info_ref = null
	new_seed_val_set = false
	($Buttons as ButtonGridContainer).disable_buttons()
	hide()


func _set_seed_text(seed_val: int) -> void:
	$Seed.text = "Seed: %d" % seed_val


func _set_mode_text(mode: String) -> void:
	$Mode.text = "Mode: %s" % mode


func _on_GameOver_draw() -> void:
	if info_ref != null:
		$Score.text = "Score: %d" % info_ref.get_score()


func _on_GiveUp_button_effects_finished() -> void:
	emit_signal("leave")


func _on_Arise_button_effects_finished() -> void:
	if new_seed_val_set:
		emit_signal("retry", new_seed_val)
	else:
		emit_signal("retry")


func _on_Arise_button_input(event: InputEvent) -> void:
	if event.is_action("button_options", true):
		($Buttons as GridContainer).disable_buttons()
		($SeedDialog as LineDialog).prompt_integer("Seed:")


func _on_SeedDialog_integer_prompt_finished(text_entered: bool, value: int) -> void:
	if text_entered:
		new_seed_val = value
		new_seed_val_set = true

	# Delay the re-enabling of buttons to ensure that they don't accidently activate.
	($Buttons as GridContainer).call_deferred("enable_buttons")


func _on_SeedDialog_text_rejected() -> void:
	($Alert as AnimationPlayer).play()
