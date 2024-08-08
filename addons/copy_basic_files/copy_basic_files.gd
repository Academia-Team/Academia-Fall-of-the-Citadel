tool
extends EditorPlugin

var copy_basic_files_plugin: EditorExportPlugin = preload("export.gd").new()


func _enter_tree():
	add_export_plugin(copy_basic_files_plugin)


func _exit_tree():
	remove_export_plugin(copy_basic_files_plugin)
