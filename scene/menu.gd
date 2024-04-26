extends ColorRect

const game_scene = preload("res://scene/gamescr.tscn")

func _ready():
	yield(self, "ready")
	$enter_button.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		$perish_button.emit_signal("pressed")

func _on_enter_button_pressed():
	var status = get_tree().change_scene_to(game_scene)
	
	if status != OK:
			printerr("Failed to switch to game.")

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
