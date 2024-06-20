extends ColorRect


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("Fade In")


# Allow for skipping the animation.
func _process(_delta):
	if Input.is_action_just_pressed("ui_advance"):
		var next_anim = $AnimationPlayer.animation_get_next($AnimationPlayer.current_animation)

		$AnimationPlayer.emit_signal("animation_finished", $AnimationPlayer.current_animation)
		$AnimationPlayer.play(next_anim)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade Out":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Sound.stop()
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
