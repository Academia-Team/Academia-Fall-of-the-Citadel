# Prioritizes Expirable items over non-Expirable items.

class_name OrderedStack
extends Reference

signal contents_changed

var _untimed_items := Stack.new()
var _timed_items := Stack.new()


func _init() -> void:
	var untimed_status: int = _untimed_items.connect(
		"contents_changed", self, "_on_contents_changed"
	)
	var timed_status: int = _timed_items.connect("contents_changed", self, "_on_contents_changed")

	if untimed_status != OK or timed_status != OK:
		printerr("OrderedStack will not track all messages.")


# Allocates room for the given size of items for both Expirable and
# non-Expriable items.
func set_size(size: int) -> void:
	_untimed_items.set_size(size)
	_timed_items.set_size(size)


func get_size() -> int:
	return _untimed_items.get_size()


# Returns if there is no more room for any type of item.
func is_full() -> bool:
	return _untimed_items.is_full() or _timed_items.is_full()


# Returns if there are no messages of any type.
func is_empty() -> bool:
	return _untimed_items.is_empty() and _timed_items.is_empty()


func peek():
	if not _timed_items.is_empty():
		return _timed_items.peek().get_item()
	return _untimed_items.peek()


func pop():
	if not _timed_items.is_empty():
		return _timed_items.pop().get_item()
	return _untimed_items.pop()


func discard_top() -> void:
	if not _timed_items.is_empty():
		_timed_items.discard_top()
	else:
		_untimed_items.discard_top()


func push(item, silent: bool = false) -> bool:
	if item is Expirable:
		return _timed_items.push(item, silent)
	return _untimed_items.push(item, silent)


func clear() -> void:
	_timed_items.clear()
	_untimed_items.clear()


func get_first():
	var value = null
	if not _untimed_items.is_empty():
		value = _untimed_items.get_first()
	elif not _timed_items.is_empty():
		var timed_item: Expirable = _timed_items.get_first()
		value = timed_item.get_item()
	return value


func preserve_only_first() -> void:
	if _untimed_items.is_empty():
		_timed_items.preserve_only_first()
	else:
		_timed_items.clear()
		_untimed_items.preserve_only_first()


func _on_contents_changed() -> void:
	emit_signal("contents_changed")
