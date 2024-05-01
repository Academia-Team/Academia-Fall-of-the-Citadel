extends ColorRect

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("Fade In")
	
# Allow for skipping the animation.
func _process(_delta):
	if Input.is_action_just_pressed("ui_advance"):
		var remaining_anim_len = $AnimationPlayer.current_animation_length - \
			$AnimationPlayer.current_animation_position
		$AnimationPlayer.advance(remaining_anim_len)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade Out":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
