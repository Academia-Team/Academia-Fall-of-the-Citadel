extends ColorRect

var finish_intro := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("Fade In")


# Allow for skipping the animation.
func _process(_delta: float) -> void:
	if not finish_intro and Input.is_action_just_pressed("ui_advance"):
		_advance_to_end()


func _advance_to_end() -> void:
	$AnimationPlayer.advance(99999)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Fade Out":
		finish_intro = true
		$Sound.stop()
		$Menu.enable()
