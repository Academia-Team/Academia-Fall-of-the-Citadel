extends ColorRect

const menu_scene = preload("res://scene/menu.tscn")

func _ready():
	$AnimationPlayer.play("Fade In")
	
# Allow for skipping the animation.
func _unhandled_input(event):
	if event is InputEventKey or \
		event is InputEventGesture or \
		event is InputEventJoypadButton or \
		event is InputEventJoypadMotion or \
		event is InputEventMouseButton:
		$AnimationPlayer.emit_signal("animation_finished")

func _on_AnimationPlayer_animation_finished(anim_name):
	var status = get_tree().change_scene_to(menu_scene)
	
	if status != OK:
			printerr("Failed to switch to menu.")
