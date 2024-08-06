tool
extends EditorImportPlugin

func get_importer_name() -> String:
	return "academia_team.txt"

func get_visible_name() -> String:
	return "txt"

func get_recognized_extensions() -> Array:
	return [ "txt" ]

func get_save_extension() -> String:
	return "res"

func get_resource_type() -> String:
	return "PlainTextFile"

func get_preset_count() -> int:
	return 0

func get_input_options() -> Array:
	return []

func get_option_visibility(_option: String, _options: Dictionary) -> bool:
	return true

func import(source_file: String, save_path: String, _options: Dictionary, _platform_variants: Array, _gen_files: Array) -> int:
	var file: File = File.new()
	var status: int = file.open(source_file, File.READ)

	if status != OK:
		return status
	
	var text: String = file.get_as_text()
	var text_file: PlainTextFile = PlainTextFile.new()
	text_file.text = text
	text_file.close()
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], text_file)
