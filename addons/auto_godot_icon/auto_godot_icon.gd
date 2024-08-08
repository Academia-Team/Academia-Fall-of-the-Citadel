tool
extends EditorPlugin

var auto_godot_icon_plugin: EditorExportPlugin = preload("export.gd").new()


func _enter_tree():
	add_export_plugin(auto_godot_icon_plugin)


func _exit_tree():
	remove_export_plugin(auto_godot_icon_plugin)
