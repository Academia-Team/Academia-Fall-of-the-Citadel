extends ColorRect

signal leave
signal retry

var info_ref: InfoBar = null


func _ready():
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


func _on_Arise_button_effects_finished():
	emit_signal("retry")
