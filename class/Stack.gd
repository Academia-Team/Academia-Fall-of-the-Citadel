class_name Stack
extends Reference

signal contents_changed

var _max_items := 0
var _stack := []
var _num_items := 0 setget , get_size


func set_size(size: int) -> void:
	if size < _max_items:
		emit_signal("contents_changed")
	_stack.resize(size)
	_max_items = size


func get_size() -> int:
	return _num_items


func is_full() -> bool:
	return _num_items == _max_items


func is_empty() -> bool:
	return _num_items == 0


func peek():
	if _pop_expired() > 0:
		emit_signal("contents_changed")
	if _num_items > 0:
		return _stack[_num_items - 1]
	return null


func pop():
	var item
	if _num_items > 0:
		_num_items -= 1
		item = _stack[_num_items]
		# warning-ignore: return_value_discarded
		_pop_expired()
		emit_signal("contents_changed")
	return item


func discard_top() -> void:
	# warning-ignore: return_value_discarded
	pop()


func push(item, silent: bool = false) -> bool:
	if is_full():
		return false
	if item is Expirable:
		var connect_status: int = item.connect("expired", self, "_on_item_expired")
		if connect_status != OK or item.is_expired():
			return false
	_stack[_num_items] = item
	_num_items += 1

	if not silent:
		emit_signal("contents_changed")

	return true


func clear() -> void:
	if _num_items > 0:
		_num_items = 0
		emit_signal("contents_changed")


func get_first():
	var item = null
	for i in range(_num_items):
		if not _stack[i] is Expirable or not _stack[i].is_expired():
			item = _stack[i]
			break
	return item


func preserve_only_first() -> void:
	if _num_items > 1:
		var first_item = get_first()
		if first_item != null:
			_stack[0] = first_item
			_num_items = 1
		else:
			clear()
		emit_signal("contents_changed")


func _on_item_expired() -> void:
	var num_popped: int = _pop_expired()
	if num_popped > 0:
		emit_signal("contents_changed")


func _pop_expired() -> int:
	var item_popped: bool = true
	var num_popped: int = 0
	while item_popped:
		item_popped = _pop_expired_item() != null
		if item_popped:
			num_popped += 1
	return num_popped


func _pop_expired_item():
	var top_item_idx: int = _num_items - 1
	var expired_item = null

	if top_item_idx >= 0:
		var top_item = _stack[top_item_idx]

		if top_item is Expirable and top_item.is_expired():
			expired_item = top_item
			_num_items = top_item_idx

	return expired_item
