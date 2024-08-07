class_name Version
extends Reference

const VER_PATH: String = "res://VERSION.txt"

var _ver: String = ""


func _init() -> void:
	var ver_file = File.new()

	if ver_file.file_exists(VER_PATH):
		var status: int = ver_file.open(VER_PATH, File.READ)

		if status == OK:
			_ver = ver_file.get_line()
			ver_file.close()
		else:
			printerr('Failed to open "%s".' % VER_PATH)
	else:
		printerr('File "%s" does not exist.' % VER_PATH)


func get_version() -> String:
	return _ver


func is_dev() -> bool:
	return ProjectSettings.get_setting("global/Dev")
