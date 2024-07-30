class_name FocusedButton
extends Button


func _ready() -> void:
	var m_entered_status: int = connect("mouse_entered", self, "_on_mouse_entered")
	var m_exited_status: int = connect("mouse_exited", self, "_on_mouse_exited")
	var f_exited_status: int = connect("focus_entered", self, "_on_focus_entered")

	if not (m_entered_status == OK or m_exited_status == OK or f_exited_status == OK):
		printerr("Internal FocusedButton Failure.")


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()


func _on_focus_entered() -> void:
	warp_mouse(Vector2.ZERO)
