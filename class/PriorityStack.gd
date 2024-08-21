# Prioritizes certain items over others.
#
# Expirable items always have greater priority since if they are not dealt with in a resonable
# time, certain actions might be missed.
#
# The higher the priority level, the higher the items in that level will be on the stack.

class_name PriorityStack
extends Reference

signal contents_changed

var global_size := 0 setget set_global_size, get_global_size
var priority_levels := 0 setget set_priority_levels, get_priority_levels

var _items := []


func set_priority_levels(value: int) -> void:
	if value > 0:
		if value < priority_levels:
			emit_signal("contents_changed")
		else:
			_items.resize(value)

			for i in range(priority_levels, value):
				_items[i] = OrderedStack.new()
				_items[i].set_size(global_size)

				var connect_status: int = _items[i].connect(
					"contents_changed", self, "_on_contents_changed"
				)
				if connect_status != OK:
					printerr("Unable to properly respond to priority level %d." % i)

		priority_levels = value


func get_priority_levels() -> int:
	return priority_levels


func valid_priority_level(level: int) -> bool:
	return level in range(priority_levels)


func get_level(level: int) -> OrderedStack:
	if valid_priority_level(level):
		return _items[level]
	return null


func set_global_size(value: int) -> void:
	if value > 0:
		global_size = value

		for i in range(priority_levels):
			(_items[i] as OrderedStack).set_size(global_size)


func get_global_size() -> int:
	return global_size


func get_full_levels() -> Array:
	var full_levels := []
	for i in range(priority_levels):
		if _items[i].is_full():
			full_levels.append(i)
	return full_levels


func get_empty_levels() -> Array:
	var empty_levels := []
	for i in range(priority_levels):
		if _items[i].is_empty():
			empty_levels.append(i)
	return empty_levels


# Returns a negative number if no priority level with content was found.
func highest_level_with_content() -> int:
	for i in range(priority_levels - 1, -1, -1):
		if not _items[i].is_empty():
			return i
	return -1


# Returns a negative number if no priority level with content was found.
func lowest_level_with_content() -> int:
	for i in range(priority_levels):
		if not _items[i].is_empty():
			return i
	return -1


func peek():
	var level: int = highest_level_with_content()
	if valid_priority_level(level):
		return (_items[level] as OrderedStack).peek()
	return null


func pop():
	var level: int = highest_level_with_content()
	if valid_priority_level(level):
		return (_items[level] as OrderedStack).pop()
	return null


func discard_top() -> void:
	var level: int = highest_level_with_content()
	if valid_priority_level(level):
		(_items[level] as OrderedStack).discard_top()


func push(item, silent: bool = false) -> bool:
	var level: int = priority_levels - 1
	if valid_priority_level(level):
		return (_items[level] as OrderedStack).push(item, silent)
	return false


func clear() -> void:
	for i in range(priority_levels):
		_items[i].clear()


func get_first():
	var level: int = lowest_level_with_content()
	if valid_priority_level(level):
		return (_items[level] as OrderedStack).get_first()
	return null


func preserve_only_first() -> void:
	var level: int = lowest_level_with_content()
	if valid_priority_level(level):
		for i in range(level + 1, priority_levels):
			(_items[i] as OrderedStack).clear()
		(_items[level] as OrderedStack).preserve_only_first()


func _on_contents_changed() -> void:
	emit_signal("contents_changed")
