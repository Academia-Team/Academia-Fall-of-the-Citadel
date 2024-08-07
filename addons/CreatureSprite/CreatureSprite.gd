tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("CreatureSprite", "Sprite", preload("type.gd"), preload("res://Icon.png"))


func _exit_tree() -> void:
	remove_custom_type("CreatureSprite")
