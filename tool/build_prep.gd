extends SceneTree

const EXPORT_PRESET_PATH := "res://export_presets.cfg"


func _init() -> void:
	var project_dir := Directory.new()
	var open_status: int = project_dir.open("res://")

	if open_status != OK:
		printerr("Cannot access project directory.")
		quit(1)
		return

	var paths_to_make: Array = _get_export_dir_dests()

	if paths_to_make.empty():
		printerr("Failed to get export paths.")
		printerr("Please ensure you are running the script in a Godot project.")
		quit(1)
		return

	var build_dir: String = _get_largest_array_substring(paths_to_make)

	if build_dir.empty():
		printerr("The found export paths have no build directory in common.")
		quit(1)
		return

	if project_dir.dir_exists(build_dir):
		var removal_status: int = _remove_all(project_dir, build_dir)
		if removal_status != OK:
			printerr('Cannot clean up "%s".' % build_dir)
			quit(1)
			return

	for path in paths_to_make:
		var dir_create_status: int = project_dir.make_dir_recursive(path)

		if dir_create_status != OK:
			printerr('Failed to create "%s".' % path)
			var removal_status: int = _remove_all(project_dir, build_dir)
			if removal_status != OK:
				printerr("Failed to cleanup after error.")
			quit(1)
			return

	quit()


func _remove_all(dir: Directory, path: String) -> int:
	var curr_path: String = dir.get_current_dir()
	var dir_change_status: int = dir.change_dir(path)
	var overall_status := OK
	var found_dirs := []

	if dir_change_status != OK:
		printerr('Failed to change to "%s".' % path)
		return dir_change_status

	overall_status = dir.list_dir_begin(true)
	if overall_status == OK:
		var item_name: String = dir.get_next()
		while overall_status == OK and not item_name.empty():
			if dir.current_is_dir():
				found_dirs.append(item_name)
			else:
				overall_status = dir.remove(item_name)
				if overall_status != OK:
					printerr(
						'Failed to remove file "%s" in "%s".' % [item_name, dir.get_current_dir()]
					)
			item_name = dir.get_next()
		dir.list_dir_end()

	if overall_status == OK:
		for found_dir in found_dirs:
			overall_status = _remove_all(dir, found_dir)
			if overall_status != OK:
				break

	var dir_revert_status: int = dir.change_dir(curr_path)
	if dir_revert_status != OK:
		printerr('Failed to change to "%s".' % curr_path)
		return dir_revert_status

	if overall_status == OK:
		overall_status = dir.remove(path)
	return overall_status


func _get_export_dir_dests() -> Array:
	var export_dests := []
	var export_file := File.new()
	var export_file_status: int = export_file.open(EXPORT_PRESET_PATH, File.READ)

	if export_file_status == OK:
		while export_file.get_position() < export_file.get_len() and export_file.get_error() == OK:
			var line: String = export_file.get_line()
			if line.begins_with("export_path="):
				var export_dest: String = _get_line_value(line)
				var abs_export_dest: String = _get_abs_path(export_dest)
				var abs_base_path: String = abs_export_dest.get_base_dir()
				export_dests.append(abs_base_path)

		export_file.close()
	else:
		printerr('Failed to open "%s".' % EXPORT_PRESET_PATH)

	return export_dests


func _get_line_value(line: String) -> String:
	line = line.get_slice("=", 1)
	line = line.trim_prefix('"')
	line = line.trim_suffix('"')

	return line


func _get_abs_path(rel_path: String) -> String:
	var complete_path := "res://" + rel_path
	return ProjectSettings.globalize_path(complete_path)


func _get_largest_common_substring(str1: String, str2: String) -> String:
	var same := true
	var smallest_size: int
	var str1_size: int = str1.length()
	var str2_size: int = str2.length()

	if str1_size < str2_size:
		smallest_size = str1_size
	else:
		smallest_size = str2_size

	var substring := ""

	var i := 0
	while i < smallest_size and same:
		same = str1[i] == str2[i]

		if same:
			substring += str1[i]

		i += 1

	return String(substring)


func _get_largest_array_substring(array: Array) -> String:
	var array_len: int = array.size()
	var substring := ""

	if array_len > 0:
		substring = array[0]

	var i := 1
	while i < array_len and not substring.empty():
		substring = _get_largest_common_substring(substring, array[i])
		i += 1

	return substring
