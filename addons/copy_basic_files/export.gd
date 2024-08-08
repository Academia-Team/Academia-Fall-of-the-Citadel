tool
extends EditorExportPlugin

const DESIRED_FILES_PROPERTY: String = "global/files_to_add_on_export"
const TARGET_FEATURE: String = "directly_viewable"

var target_dir: String = ""


func _export_begin(features: PoolStringArray, _is_debug: bool, path: String, _flags: int) -> void:
	if TARGET_FEATURE in features:
		target_dir = path.get_base_dir()


func _export_end() -> void:
	if ProjectSettings.has_setting(DESIRED_FILES_PROPERTY) and not target_dir.empty():
		var project_dir: Directory = Directory.new()
		var project_dir_status: int = project_dir.open("res://")

		if project_dir_status == OK:
			for source_path in ProjectSettings.get_setting(DESIRED_FILES_PROPERTY):
				var dest_path: String = "%s/%s" % [target_dir, source_path.get_file()]
				var copy_status: int = project_dir.copy(source_path, dest_path)

				if copy_status != OK:
					printerr('Failed to copy "%s" to "%s".' % [source_path, dest_path])
					break
		else:
			printerr("Cannot open project directory.")
