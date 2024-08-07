tool
extends Label

export var file_path: String = ""


func _enter_tree() -> void:
	if not file_path.empty():
		var file: File = File.new()
		if file.file_exists(file_path):
			var file_status: int = file.open(file_path, File.READ)
			if file_status == OK:
				text = file.get_as_text()
			else:
				printerr('Cannot open "%s".' % file.get_path())
		else:
			printerr('File "%s" does not exist.' % file_path)
