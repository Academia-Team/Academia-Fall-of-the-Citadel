class_name InfoBar
extends ColorRect

export var default_timed_message_length: int = 3
export var num_messages_to_support: int = 10 setget set_num_messages, get_num_messages

var _initial_lives = 0
var _mode = null
var _score = 0
var _seed = null
var _status_messages: OrderedMessageStack = OrderedMessageStack.new()

var _cheat_enabled = false
var _tainted = false


func _ready():
	_status_messages.set_size(num_messages_to_support)
	var message_connect: int = _status_messages.connect(
		"contents_changed", self, "_on_status_contents_changed"
	)
	if message_connect != OK:
		printerr("Cannot display status messages.")

	var initial_message: Message = Message.new($Status.text)
	var push_success: bool = _status_messages.push(initial_message)
	if not push_success:
		printerr("Failed to display initial status message.")


func reset():
	$StatusTimer.stop()
	_cheat_enabled = false
	_initial_lives = 0
	_score = 0
	_seed = null
	_tainted = false

	_write_score_text()
	reset_status()


func update_score(score_delta):
	_score += score_delta
	_write_score_text()


func _write_score_text():
	$ScoreCounter.text = "Score: %d" % _score


func set_mode(mode):
	_mode = mode


func get_mode():
	return _mode


func get_score():
	return _score


func display_lives(life_count):
	if _initial_lives == 0:
		_initial_lives = life_count
	$LivesCounter.text = "Lives: %d / %d" % [life_count, _initial_lives]


func set_seed(seed_val):
	_seed = seed_val


func get_seed():
	return _seed


func set_timed_status(status_str, sec = default_timed_message_length):
	var timer: SceneTreeTimer = get_tree().create_timer(sec)
	var message: TimedMessage = TimedMessage.new(status_str, timer)
	var message_success: bool = _status_messages.push(message)
	if not message_success:
		printerr('Failed to display message "%s" for %f seconds' % [status_str, sec])


# All timed status messages have priority above non-timed status messages.
func set_status(status_str):
	var message: Message = Message.new(status_str)
	var message_success: bool = _status_messages.push(message)
	if not message_success:
		printerr('Failed to display message "%s".' % status_str)


func get_status():
	var status: String = ""
	var message: Message = _status_messages.peek()
	if message != null:
		status = message.get_message()
	return status


# Discards all messages except the first one.
func reset_status():
	_status_messages.preserve_only_first()


func toggle_cheats():
	_cheat_enabled = not _cheat_enabled
	_tainted = true


func is_cheat_enabled():
	return _cheat_enabled


func is_tainted():
	return _tainted


func set_num_messages(value: int) -> void:
	num_messages_to_support = value
	_status_messages.set_size(value)


func get_num_messages() -> int:
	return num_messages_to_support


func _on_status_contents_changed() -> void:
	var message: Message = _status_messages.peek()
	if message != null:
		$Status.text = message.get_message()
	else:
		$Status.text = ""
