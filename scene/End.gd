extends ColorRect


func _ready():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
