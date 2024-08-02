class_name LineDialog
extends PopupPanel

signal integer_prompt_finished(text_entered, value)
signal text_rejected

const MAX_INT_LEN: int = 19

export var line_length: int = 0

var _int_value: int = 0
var _int_entered: bool = false

var _text_handled: bool = false


func _ready() -> void:
	($HBoxContainer/Line as LineEdit).max_length = line_length


func _display_prompt(label_name: String) -> void:
	($HBoxContainer/Label as Label).text = label_name
	($HBoxContainer/Line as LineEdit).text = ""
	show_modal()
	($HBoxContainer/Line as Control).grab_focus()


func prompt_integer(label_name: String) -> void:
	_display_prompt(label_name)
	yield(self, "hide")

	emit_signal("integer_prompt_finished", _int_entered, _int_value)
	_int_entered = false


func _on_Line_text_entered(new_text: String) -> void:
	_int_value = 0

	if new_text.is_valid_integer() and new_text.length() <= MAX_INT_LEN + int(new_text[0] == "-"):
		_int_value = new_text.to_int()
	else:
		_int_value = hash(new_text)

	_int_entered = true

	hide()


func _on_Line_text_change_rejected(_rejected_substring: String) -> void:
	emit_signal("text_rejected")
	_text_handled = true


func _on_Line_text_changed(_new_text: String) -> void:
	_text_handled = true


func _on_Line_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cntrl") and not _text_handled:
		emit_signal("text_rejected")

	_text_handled = false


func _on_LineDialog_about_to_show() -> void:
	($HBoxContainer/Line as Control).grab_focus()
