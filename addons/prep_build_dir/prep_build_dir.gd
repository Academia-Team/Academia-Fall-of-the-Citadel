tool
extends EditorPlugin

var prep_build_dir_plugin: EditorExportPlugin = preload("export.gd").new()


func _enter_tree() -> void:
	add_export_plugin(prep_build_dir_plugin)


func _exit_tree() -> void:
	remove_export_plugin(prep_build_dir_plugin)
