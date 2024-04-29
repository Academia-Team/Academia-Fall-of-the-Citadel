extends ColorRect

func _ready():
	$AnimationPlayer.play("Fade In")
	
# Allow for skipping the animation.
func _unhandled_input(event):
	if event is InputEventKey or \
		event is InputEventGesture or \
		event is InputEventJoypadButton or \
		event is InputEventJoypadMotion or \
		event is InputEventMouseButton:
			var remaining_anim_len = $AnimationPlayer.current_animation_length - \
				$AnimationPlayer.current_animation_position
			$AnimationPlayer.advance(remaining_anim_len)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade Out":
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
