extends ColorRect

func _ready():
	$enter_button.grab_focus()

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
