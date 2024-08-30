# Adds helper methods to a TileMap to make it easier to create a game world.

class_name TileWorld
extends TileMap

signal message_change_request(text, duration, priority)
signal music_change_request(stream, priority)
signal tint_changed(color)
signal event_started(event)
signal event_finished(event)

const EVENT_NO_LIMIT := -1

const MAX_TINT_REQUESTS := 3

var _tint_stack := TriPriorityStack.new()


class Event:
	extends Reference

	var num_times: int
	var max_times: int

	var identifier: int
	var message: String
	var music: AudioStream
	var game_tint: Color

	func _init(
		id: int,
		text: String = "",
		max_occurences: int = EVENT_NO_LIMIT,
		song: AudioStream = null,
		tint: Color = Color.white
	):
		identifier = id
		num_times = 0
		max_times = max_occurences

		message = text
		music = song
		game_tint = tint


func _init() -> void:
	_tint_stack.set_global_size(MAX_TINT_REQUESTS)

	var tint_connect: int = _tint_stack.connect("contents_changed", self, "_on_tint_changed")
	if tint_connect == OK:
		var low_stack: OrderedStack = _tint_stack.get_level(_tint_stack.LOW_PRIORITY)
		if low_stack != null:
			var push_success: bool = low_stack.push(modulate)
			if not push_success:
				printerr("Failed to push initial tinting.")
		else:
			printerr("Cannot access priority level used for initial tinting.")
	else:
		printerr("Unable to keep track of requests for tinting.")


func send_event(
	event: Event, duration: float = EVENT_NO_LIMIT, priority: int = TriPriorityStack.MED_PRIORITY
) -> void:
	if event.max_times == EVENT_NO_LIMIT or event.num_times < event.max_times:
		event.num_times += 1

		if not event.message.empty():
			emit_signal("message_change_request", event.message, duration, priority)

		set_tint(event.game_tint, priority, duration)

		if event.music != null:
			emit_signal("music_change_request", event.music, priority)

		emit_signal("event_started", event)
		if duration != EVENT_NO_LIMIT:
			yield(get_tree().create_timer(duration), "timeout")
			emit_signal("event_finished", event)


func set_tint(tint: Color, priority: int = _tint_stack.MED_PRIORITY, duration: float = 0.0) -> void:
	var stack: OrderedStack = _tint_stack.get_level(priority)
	if stack != null:
		if duration <= 0:
			var push_success: bool = stack.push(tint)
			if not push_success:
				printerr("Cannot tint screen %s." % tint)
		else:
			var timer: SceneTreeTimer = get_tree().create_timer(duration)
			var timed_tint := Expirable.new(tint, timer)
			var push_success: bool = stack.push(timed_tint)
			if not push_success:
				printerr("Cannot tint screen %s for %f seconds." % [tint, duration])
	else:
		printerr("Cannot push tint to invalid priority %d." % priority)


func reset_tint() -> void:
	_tint_stack.preserve_only_first()


func pos_in_world(pos: Vector2) -> bool:
	return get_cellv(world_to_map(pos)) != INVALID_CELL


func _on_tint_changed() -> void:
	var tint = _tint_stack.peek()
	var color: Color

	if tint is Color:
		color = tint

	if tint is Expirable:
		color = tint.get_item()

	modulate = color
	emit_signal("tint_changed", color)
