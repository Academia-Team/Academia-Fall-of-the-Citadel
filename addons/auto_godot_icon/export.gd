tool
extends EditorExportPlugin

const GODOT_ICON_SCRIPT := "res://addons/godot_icon/ReplaceIcon.gd"
const TARGET_FEATURES := PoolStringArray(["64", "Windows"])
const WIN_ICON_SETTING := "application/config/windows_native_icon"

var target_executable: String


func _export_begin(features: PoolStringArray, _is_debug: bool, path: String, _flags: int):
	target_executable = ""
	var has_required_features: bool = true
	for target_feature in TARGET_FEATURES:
		has_required_features = target_feature in features
		if not has_required_features:
			break

	if has_required_features:
		target_executable = path


func _export_end():
	if not target_executable.empty():
		var abs_script_path: String = ProjectSettings.globalize_path(GODOT_ICON_SCRIPT)
		var win_icon_path: String = ProjectSettings.get_setting(WIN_ICON_SETTING)
		var abs_win_icon_path: String = ProjectSettings.globalize_path(win_icon_path)

		var script_return_code: int = OS.execute(
			OS.get_executable_path(),
			["-s", abs_script_path, abs_win_icon_path, target_executable],
			true
		)
		if script_return_code != 0:
			printerr('An unknown error occurred while attempting to run "%s".' % abs_script_path)
