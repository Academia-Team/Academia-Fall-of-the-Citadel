extends SceneTree

const DEV_PROPERTY: String = "global/Dev"
const EXPORT_ALL_PATH: String = "res://tool/export_all.gd"
const EXPORT_PRESET_PATH: String = "res://export_presets.cfg"
const PUBLISH_PRESET_PROPERTY: String = "global/Itch Presets To Publish"
const VERSION_PATH: String = "res://VERSION.txt"

const USER_ARG: int = 0
const GAME_ARG: int = 1
const REQ_NUM_ARGS: int = 2

var godot_exec_path: String


class Args:
	enum Status { VALID, MISSING_USER, MISSING_GAME, UNPROCESSED, INVALID, TOO_MANY }
	var status: int = Status.UNPROCESSED
	var username: String = ""
	var gamename: String = ""


func _init() -> void:
	var raw_args: PoolStringArray = OS.get_cmdline_args()
	var args: Args = _parse_args(raw_args)

	if not _should_arg_continue(args):
		var message: String = _get_arg_message(args)
		if not message.empty():
			printerr(message)
			printerr()
		printerr(_get_help_msg())
		quit(1)
		return

	if (
		ProjectSettings.has_setting(DEV_PROPERTY)
		and (ProjectSettings.get_setting(DEV_PROPERTY) as bool)
	):
		printerr("Current build is in development.")
		printerr('Cannot publish without "%s" being false.' % DEV_PROPERTY)
		quit(1)
		return

	godot_exec_path = OS.get_executable_path()

	var preset_channel: Dictionary = _get_publish_info()
	if preset_channel.empty():
		printerr('Property "%s" is either empty or non-existant.' % PUBLISH_PRESET_PROPERTY)
		printerr("Please ensure you are running the script in a Godot project.")
		quit(1)
		return

	if not _validate_publish_info(preset_channel):
		printerr('Property "%s" contains invalid data.' % PUBLISH_PRESET_PROPERTY)
		quit(1)
		return

	var channel_path: Dictionary = _get_channel_path(preset_channel)
	var channel_path_size: int = channel_path.size()
	var preset_channel_size: int = preset_channel.size()
	if channel_path_size != preset_channel_size:
		printerr(
			(
				"Expected %d presets to export but only got %d."
				% [preset_channel_size, channel_path_size]
			)
		)
		quit(1)
		return

	var export_all_return_code: int = _run_export_all()
	if export_all_return_code != 0:
		printerr('Failed to run "%s".' % EXPORT_ALL_PATH)
		quit(1)
		return

	for channel in channel_path:
		print("%s:" % channel)
		var publish_return_code: int = publish(
			channel_path[channel], channel, args.username, args.gamename
		)
		if publish_return_code != 0:
			printerr('Failed to upload "%s" to channel "%s".' % [channel_path[channel], channel])
			quit(1)
			return
		print()
	quit(0)


func _strip_godot_engine_args(raw_args: PoolStringArray) -> PoolStringArray:
	var script_args: PoolStringArray = PoolStringArray()
	var script_name_idx: int = 0

	for arg in raw_args:
		script_name_idx += 1
		if arg == "-s" or arg == "--script":
			break

	var i: int = script_name_idx + 1
	while i < raw_args.size():
		script_args.append(raw_args[i])
		i += 1

	return script_args


func _parse_args(raw_args: PoolStringArray) -> Args:
	var args: Args = Args.new()
	var script_args: PoolStringArray = _strip_godot_engine_args(raw_args)
	var num_args: int = script_args.size()
	var valid: bool = true

	if num_args == REQ_NUM_ARGS:
		for arg in script_args:
			if arg.begins_with("-"):
				valid = false
				break
		if not valid:
			args.status = Args.Status.INVALID
		else:
			args.username = script_args[USER_ARG]
			args.gamename = script_args[GAME_ARG]
			args.status = Args.Status.VALID
	elif num_args == 1:
		if script_args[0].begins_with("-"):
			args.status = Args.Status.INVALID
		else:
			args.status = Args.Status.MISSING_GAME
	elif num_args == 0:
		args.status = Args.Status.MISSING_USER
	else:
		args.status = Args.Status.TOO_MANY
	return args


func _should_arg_continue(args: Args) -> bool:
	return args.status == Args.Status.VALID


func _get_arg_message(args: Args) -> String:
	match args.status:
		Args.Status.VALID:
			return "Arguments are valid. An internal error has occurred."
		Args.Status.MISSING_USER:
			return "Missing Itch.io username."
		Args.Status.MISSING_GAME:
			return "Missing Itch.io gamename."
		Args.Status.UNPROCESSED:
			return "Arguments have not been processed. An internal error has occurred."
		Args.Status.INVALID:
			return "The provided arguments are invalid."
		Args.Status.TOO_MANY:
			return "Too many arguments have been provided."
		_:
			return "Status %d is not handled." % args.status


func _get_help_msg() -> String:
	return """
itch_publish.gd <username> <gamename>

For example, "itch_publish.gd techpowerawaits acadfoc" corresponds to the
https://techpowerawaits.itch.io/acadfoc

Butler is used and must be available from the System Path. As well, logging in
to Butler is required before usage of this script.
"""


func _run_export_all() -> int:
	var abs_build_prep_path: String = ProjectSettings.globalize_path(EXPORT_ALL_PATH)
	return OS.execute(godot_exec_path, ["-s", abs_build_prep_path], true)


func _get_publish_info() -> Dictionary:
	var publish_info: Dictionary = {}

	if ProjectSettings.has_setting(PUBLISH_PRESET_PROPERTY):
		publish_info = ProjectSettings.get_setting(PUBLISH_PRESET_PROPERTY)

	return publish_info


func _validate_publish_info(publish_info: Dictionary) -> bool:
	var valid: bool = true
	var keys: Array = publish_info.keys()

	for key in keys:
		var occurances: int = keys.count(key)
		valid = valid and occurances == 1
		if not valid:
			printerr('Channel "%s" appears %d times.' % [key, occurances])

	return valid


func _get_channel_path(preset_channel: Dictionary) -> Dictionary:
	var channel_path: Dictionary = {}
	var export_file: File = File.new()
	var export_file_status: int = export_file.open(EXPORT_PRESET_PATH, File.READ)

	if export_file_status == OK:
		var desired_dict: Dictionary = {}
		var find_path: bool = false
		var presets_found: int = 0
		var presets_handled: int = 0
		var channel_name: String = ""

		while export_file.get_position() < export_file.get_len() and export_file.get_error() == OK:
			var line: String = export_file.get_line()
			if line.begins_with("name="):
				var preset_name: String = _get_line_value(line)
				if preset_name in preset_channel:
					channel_name = preset_channel[preset_name]
					find_path = true
					presets_found += 1
			elif line.begins_with("export_path=") and find_path:
				var export_dest: String = _get_line_value(line)
				var abs_export_dest: String = _get_abs_path(export_dest)
				var abs_base_path: String = abs_export_dest.get_base_dir()
				desired_dict[channel_name] = abs_base_path
				presets_handled += 1
				find_path = false

		export_file.close()

		if presets_found == presets_handled:
			channel_path = desired_dict
		else:
			printerr(
				(
					"%d publishable presets were found, but only %d were processed."
					% [presets_found, presets_handled]
				)
			)
	else:
		printerr('Failed to open "%s".' % EXPORT_PRESET_PATH)

	return channel_path


func _get_line_value(line: String) -> String:
	line = line.get_slice("=", 1)
	line = line.trim_prefix('"')
	line = line.trim_suffix('"')

	return line


func _get_abs_path(rel_path: String) -> String:
	var complete_path: String = "res://" + rel_path
	return ProjectSettings.globalize_path(complete_path)


func publish(path: String, channel: String, user: String, game: String) -> int:
	var abs_version_file_path: String = ProjectSettings.globalize_path(VERSION_PATH)
	var upload_target: String = "%s/%s:%s" % [user, game, channel]
	var output: Array = []

	var return_code: int = OS.execute(
		"butler",
		["push", path, upload_target, "--userversion-file", abs_version_file_path],
		true,
		output
	)

	for line in output:
		print(line)

	return return_code
