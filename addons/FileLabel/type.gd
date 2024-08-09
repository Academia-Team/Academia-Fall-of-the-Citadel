tool
extends Label

export(String, FILE) var file_path: String = "" setget set_file_path


func set_file_path(path: String) -> void:
	text = ""
	file_path = path

	if not file_path.empty():
		var file: File = File.new()
		if file.file_exists(file_path):
			var file_status: int = file.open(file_path, File.READ)
			if file_status == OK:
				text = file.get_as_text()
				file.close()
			else:
				printerr('Cannot open "%s".' % file.get_path())
		else:
			printerr('File "%s" does not exist.' % file_path)
