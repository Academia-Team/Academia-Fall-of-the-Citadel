extends ColorRect

const game_scene = preload("res://scene/gamescr.tscn")

func _ready():
	$enter_button.grab_focus()

func _process(_delta):
	if Input.is_action_pressed("quit"):
		$perish_button.emit_signal("pressed")

func _on_enter_button_pressed():
	get_tree().change_scene_to(game_scene)

func _on_perish_button_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
