class_name ButtonGridContainer
extends FocusedGridContainer


func enable_buttons() -> void:
	var children: Array = get_children()

	for child in children:
		if child is BaseButton:
			child.disabled = false


func disable_buttons() -> void:
	var children: Array = get_children()

	for child in children:
		if child is BaseButton:
			child.disabled = true
