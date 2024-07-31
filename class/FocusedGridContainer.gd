class_name FocusedGridContainer
extends GridContainer


func _ready() -> void:
	var sort_connect_status: int = connect("sort_children", self, "_on_change")
	var vis_change_status: int = connect("visibility_changed", self, "_on_change")

	if not (sort_connect_status == OK or vis_change_status == OK):
		printerr("Internal FocusedGridContainer Failure.")


func _on_change() -> void:
	var children: Array = get_children()

	for child in children:
		if child is Control and child.is_visible_in_tree():
			if child is FocusedButton:
				child.grab_silent_focus()
			else:
				child.grab_focus()
			break
