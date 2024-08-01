class_name FocusedGridContainer
extends GridContainer


func _ready() -> void:
	var vis_change_status: int = connect("visibility_changed", self, "_on_visibility_changed")

	if vis_change_status != OK:
		printerr("Internal FocusedGridContainer Failure.")

	force_focus()


func force_focus() -> void:
	var children: Array = get_children()

	for child in children:
		if child is Control and child.is_visible_in_tree():
			if child is FocusedButton:
				child.grab_silent_focus()
			else:
				child.grab_focus()
			break


func _on_visibility_changed() -> void:
	force_focus()
