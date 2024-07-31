class_name FocusedGridContainer
extends GridContainer


func _ready() -> void:
	var connect_status: int = connect("sort_children", self, "_on_sort_children")

	if connect_status != OK:
		printerr("Internal FocusedGridContainer Failure.")


func _on_sort_children() -> void:
	var children: Array = get_children()

	for child in children:
		if child is Control and child.visible:
			if child is FocusedButton:
				child.grab_silent_focus()
			else:
				child.grab_focus()
			break
