tool
extends Label

export var text_file: Resource = null


func _on_enter_tree() -> void:
	text = text_file.text
