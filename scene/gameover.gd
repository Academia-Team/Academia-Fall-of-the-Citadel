extends ColorRect

func _init():
	if $revive_button == null:
		print("Panic")
	$revive_button.grab_focus()
