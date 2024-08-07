extends SceneTree

const BUILD_DIR: String = "build"
const DESIRED_FOLDERS: Array = ["linux64", "linux86", "web", "web-main", "win64", "win86"]


func _init() -> void:
	var project_dir: Directory = Directory.new()
	var open_status: int = project_dir.open("res://")

	if open_status != OK:
		printerr("Cannot access project directory.")
		quit(1)

	if project_dir.dir_exists(BUILD_DIR):
		var removal_status: int = _remove_all(project_dir, BUILD_DIR)
		if removal_status != OK:
			quit(1)

	var make_status: int = _make_dirs(project_dir)
	if make_status != OK:
		var removal_status: int = _remove_all(project_dir, BUILD_DIR)
		if removal_status != OK:
			printerr("Failed to cleanup after error.")
			quit(1)
	quit()


func _remove_all(dir: Directory, path: String) -> int:
	var curr_path: String = dir.get_current_dir()
	var dir_change_status: int = dir.change_dir(path)
	var overall_status: int = OK
	var found_dirs: Array = []

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


func _make_dirs(dir: Directory) -> int:
	var dir_create_status: int = OK
	if not dir.dir_exists(BUILD_DIR):
		for folder_name in DESIRED_FOLDERS:
			var target_path: String = "%s/%s" % [BUILD_DIR, folder_name]
			dir_create_status = dir.make_dir_recursive(target_path)

			if dir_create_status != OK:
				printerr('Failed to create "%s".' % target_path)
				break
	return dir_create_status
