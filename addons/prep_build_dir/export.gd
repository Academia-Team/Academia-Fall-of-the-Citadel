tool
extends EditorExportPlugin

const BUILD_PREP_PATH: String = "res://tool/build_prep.gd"


func _export_begin(_features: PoolStringArray, _is_debug: bool, path: String, _flags: int) -> void:
	var project_dir: Directory = Directory.new()
	var project_dir_status: int = project_dir.open("res://")

	if project_dir_status == OK:
		var export_dir_path: String = path.get_base_dir()
		if not project_dir.dir_exists(export_dir_path):
			var build_prep_abs_path: String = ProjectSettings.globalize_path(BUILD_PREP_PATH)
			var script_exit_code: int = OS.execute(
				OS.get_executable_path(), ["-s", build_prep_abs_path], true
			)

			if script_exit_code != 0:
				printerr(
					'An unknown error occurred while attempting to run "%s".' % BUILD_PREP_PATH
				)
	else:
		printerr("Cannot open project directory.")
