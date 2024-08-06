tool
extends EditorPlugin

var importer
#var importer: EditorImportPlugin


func _enter_tree() -> void:
	#add_custom_type("PlainTextFile", "Resource", preload("PlainTextFile.gd"), preload("icon.png"))
	add_custom_type("PTFLabel", "Label", preload("PTFLabel.gd"), preload("icon.png"))
	importer = preload("import.gd").new()
	add_import_plugin(importer)


func _exit_tree() -> void:
	remove_import_plugin(importer)
	importer = null
	remove_custom_type("PTFLabel")
	#remove_custom_type("PlainTextFile")
