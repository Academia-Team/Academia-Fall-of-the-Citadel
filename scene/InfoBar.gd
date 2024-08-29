class_name InfoBar
extends ColorRect

export var default_timed_message_length := 3
export var num_messages_to_support := 10 setget set_num_messages, get_num_messages

var cheat_enabled := false setget set_cheat_enabled, is_cheat_enabled
var mode := "" setget set_mode, get_mode
var score := 0 setget set_score, get_score
var seed_value := 0 setget set_seed, get_seed

var _initial_lives := 0
var _status_messages := TriPriorityStack.new()
var _tainted := false setget , is_tainted


func _ready() -> void:
	_status_messages.set_global_size(num_messages_to_support)

	var message_connect: int = _status_messages.connect(
		"contents_changed", self, "_on_status_contents_changed"
	)
	if message_connect != OK:
		printerr("Cannot display status messages.")

	var low_priority: OrderedStack = _status_messages.get_level(_status_messages.LOW_PRIORITY)
	var push_success: bool = low_priority.push($Status.text)
	if not push_success:
		printerr("Failed to display initial status message.")


func reset() -> void:
	set_cheat_enabled(false)
	set_score(0)
	set_seed(0)
	_tainted = false

	_initial_lives = 0
	reset_status()


func set_score(value: int) -> void:
	score = value
	$ScoreCounter.text = "Score: %d" % score


func update_score(score_delta: int) -> void:
	set_score(get_score() + score_delta)


func set_mode(value: String) -> void:
	mode = value


func get_mode() -> String:
	return mode


func get_score() -> int:
	return score


func display_lives(life_count: int) -> void:
	if _initial_lives == 0:
		_initial_lives = life_count
	$LivesCounter.text = "Lives: %d / %d" % [life_count, _initial_lives]


func set_seed(value: int) -> void:
	seed_value = value


func get_seed() -> int:
	return seed_value


func set_timed_status(
	status: String,
	sec: float = default_timed_message_length,
	priority: int = _status_messages.MED_PRIORITY
) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(sec)
	var timed_message := Expirable.new(status, timer)
	var stack: OrderedStack = _status_messages.get_level(priority)

	if stack != null:
		var message_success: bool = stack.push(timed_message)
		if not message_success:
			printerr('Failed to display message "%s" for %f seconds' % [status, sec])
	else:
		printerr("Priority level %d is inaccessible." % priority)


# All timed status messages have priority above non-timed status messages.
func set_status(status: String, priority: int = _status_messages.MED_PRIORITY) -> void:
	var stack: OrderedStack = _status_messages.get_level(priority)

	if stack != null:
		var message_success: bool = stack.push(status)
		if not message_success:
			printerr('Failed to display message "%s".' % status)
	else:
		printerr("Priority level %d is inaccessible." % priority)


func get_status() -> String:
	var item = _status_messages.peek()
	if item is Expirable:
		return item.get_item()
	return item


# If the first priority is targetted, care is taken to ensure that something remains in the
# stack.
func clear_priority(priority: int) -> void:
	var stack: OrderedStack = _status_messages.get_level(priority)
	if stack != null:
		if priority == _status_messages.LOW_PRIORITY:
			stack.preserve_only_first()
		else:
			stack.clear()


# Discards all messages except the first one.
func reset_status() -> void:
	_status_messages.preserve_only_first()


func toggle_cheats() -> void:
	set_cheat_enabled(not is_cheat_enabled())


func set_cheat_enabled(value: bool) -> void:
	cheat_enabled = value
	if value:
		_tainted = true


func is_cheat_enabled() -> bool:
	return cheat_enabled


func is_tainted() -> bool:
	return _tainted


func set_num_messages(value: int) -> void:
	num_messages_to_support = value
	_status_messages.set_size(value)


func get_num_messages() -> int:
	return num_messages_to_support


func _on_status_contents_changed() -> void:
	$Status.text = get_status()
