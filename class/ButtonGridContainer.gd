class_name ButtonGridContainer
extends FocusedGridContainer

var _disabled_buttons := []


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


func hide_and_disable(button_name: String) -> bool:
	var target_button: BaseButton = get_node_or_null(button_name)

	if target_button != null:
		target_button.disabled = true
		target_button.hide()
		_disabled_buttons.append(button_name)

	return target_button != null


func are_buttons_disabled() -> bool:
	var children: Array = get_children()
	var all_disabled: bool = true

	for child in children:
		if child is BaseButton and not child.disabled:
			all_disabled = false
			break

	return all_disabled


func get_button_by_name(button_name: String) -> BaseButton:
	var children: Array = get_children()

	for child in children:
		if child is BaseButton and child.name == button_name:
			return child

	return null
