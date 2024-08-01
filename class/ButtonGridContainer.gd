class_name ButtonGridContainer
extends FocusedGridContainer

var _disabled_buttons: Array = []


func enable_buttons() -> void:
	var children: Array = get_children()

	for child in children:
		if child is BaseButton and not child.name in _disabled_buttons:
			child.disabled = false


func disable_buttons() -> void:
	var children: Array = get_children()

	for child in children:
		if child is BaseButton:
			child.disabled = true


func hide_and_disable(button_name: String) -> void:
	var target_button: BaseButton = get_node(button_name)
	target_button.disabled = true
	target_button.hide()
	_disabled_buttons.append(button_name)
