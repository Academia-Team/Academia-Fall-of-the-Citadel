extends SceneTree

const BUILD_PREP_PATH: String = "res://tool/build_prep.gd"
const EXPORT_PRESET_PATH: String = "res://export_presets.cfg"

var godot_exec_path: String


func _init() -> void:
	godot_exec_path = OS.get_executable_path()

	var build_prep_return_code: int = _run_build_prep()
	if build_prep_return_code != 0:
		printerr('Failed to run "%s".' % BUILD_PREP_PATH)
		quit(1)
		return

	var preset_path: Dictionary = _get_exports()
	if preset_path.empty():
		printerr("Failed to acquire presets to export.")
		printerr("Please ensure you are running the script in a Godot project.")
		quit(1)
		return

	for preset in preset_path:
		print("%s:" % preset)
		var export_return_code: int = _run_export(preset, preset_path[preset])
		print()
		if export_return_code != 0:
			printerr('Failed to export preset "%s".' % preset)

	quit()


func _run_build_prep() -> int:
	var abs_build_prep_path: String = ProjectSettings.globalize_path(BUILD_PREP_PATH)
	return OS.execute(godot_exec_path, ["-s", abs_build_prep_path], true)


func _get_exports() -> Dictionary:
	var export_preset_path: Dictionary = {}
	var export_file: File = File.new()
	var export_file_status: int = export_file.open(EXPORT_PRESET_PATH, File.READ)

	if export_file_status == OK:
		var desired_dict: Dictionary = {}
		var presets_found: int = 0
		var presets_handled: int = 0
		var preset_name: String = ""
		var preset_valid: bool = true

		while (
			export_file.get_position() < export_file.get_len()
			and export_file.get_error() == OK
			and preset_valid
		):
			var line: String = export_file.get_line()
			if line == "[preset.%d]" % presets_found:
				presets_found += 1
				preset_name = ""
			elif line.begins_with("name="):
				preset_name = _get_line_value(line)
				if preset_name in desired_dict:
					printerr('Preset "%s" already accounted for.')
					preset_valid = false
			elif line.begins_with("export_path="):
				var preset_path: String = _get_line_value(line)
				var preset_abs_path: String = _get_abs_path(preset_path)
				if preset_name.empty():
					printerr('No preset name associated with path "%s".' % preset_path)
					preset_valid = false
				else:
					desired_dict[preset_name] = preset_abs_path
					presets_handled += 1

		export_file.close()

		if preset_valid:
			if presets_found == presets_handled:
				export_preset_path = desired_dict
			else:
				printerr(
					(
						"%d presets were found, but only %d were processed."
						% [presets_found, presets_handled]
					)
				)
	else:
		printerr('Failed to open "%s".' % EXPORT_PRESET_PATH)

	return export_preset_path


func _get_line_value(line: String) -> String:
	line = line.get_slice("=", 1)
	line = line.trim_prefix('"')
	line = line.trim_suffix('"')

	return line


func _run_export(preset_name: String, output_path: String) -> int:
	var output: Array = []
	var exec_return_code: int = OS.execute(
		godot_exec_path, ["--export", preset_name, output_path], true, output
	)

	for line in output:
		print(line)

	return exec_return_code


func _get_abs_path(rel_path: String) -> String:
	var complete_path: String = "res://" + rel_path
	return ProjectSettings.globalize_path(complete_path)
