extends ColorRect

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
