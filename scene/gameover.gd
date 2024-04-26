extends ColorRect

func _init():
	yield(self, "ready")
	$revive_button.grab_focus()
