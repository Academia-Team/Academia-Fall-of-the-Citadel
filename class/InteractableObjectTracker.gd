# Keeps track of the number and references to all objects added to it.

class_name InteractableObjectTracker
extends Node

const COUNT_IDX: int = 0
const REF_IDX: int = 1

var _ref_counter: Dictionary = {}


func _ready() -> void:
	var status: int = connect("child_exiting_tree", self, "_on_child_exiting_tree")
	if status != OK:
		printerr("InteractableObjectTracker is unable to properly manage objects.")


# Adds the given InteractiveObject as a child of the tracker.
# The child will become associated with the given name.
func add(name: String, obj: InteractableObject) -> void:
	_set_initial_reference(name)
	if obj != null:
		add_child(obj, true)
		obj.id = _ref_counter[name][COUNT_IDX]
		var count: int = _ref_counter[name][COUNT_IDX] + 1
		var references: Array = _ref_counter[name][REF_IDX]
		references.append(obj)
		_ref_counter[name] = [count, references]


# Returns the number of objects associated with the given name.
func get_count(name: String) -> int:
	_set_initial_reference(name)
	return _ref_counter[name][COUNT_IDX]


# Returns the objects associated with the given name.
func get_references(name: String) -> Array:
	_set_initial_reference(name)
	return _ref_counter[name][REF_IDX].duplicate(true)


# Returns the first InteractiveObject that is located at the position
# (or null if no such object exists).
func get_reference_at_pos(pos: Vector2) -> InteractableObject:
	for name in _ref_counter:
		for ref in _ref_counter[name][REF_IDX]:
			if (ref as InteractableObject).position == pos:
				return ref
	return null


# Returns the first InteractiveObject that is located inside the
# rectangular region (or null if no such object exists).
func get_reference_in_area(rect: Rect2) -> InteractableObject:
	for name in _ref_counter:
		for ref in _ref_counter[name][REF_IDX]:
			if rect.has_point((ref as InteractableObject).position):
				return ref
	return null


# Removes the association of the object with its given name.
# It does not remove the object as a child.
func remove_association(name: String, obj: InteractableObject) -> InteractableObject:
	var obj_removed: InteractableObject = null
	if name in _ref_counter:
		var i: int = 0
		while i < _ref_counter[name][REF_IDX].size():
			if _ref_counter[name][REF_IDX][i].id == obj.id:
				obj_removed = _ref_counter[name][REF_IDX][i]
				_ref_counter[name][REF_IDX].remove(i)
				_ref_counter[name][COUNT_IDX] -= 1
				break
			i += 1

	return obj_removed


# Destroys all objects associated with the given name.
func clean(name: String) -> void:
	if name in _ref_counter:
		for ref in _ref_counter[name][REF_IDX]:
			remove_child(ref)


# Destroys all objects in the InteractableObjectTracker.
func cleanup() -> void:
	for child in get_children():
		remove_child(child)


# Prepares for the addition of objects to be associated
# with the given name.
func _set_initial_reference(name: String) -> void:
	if not name in _ref_counter:
		_ref_counter[name] = [0, []]


func _on_child_exiting_tree(node: Node):
	var obj_removed: InteractableObject = null
	for name in _ref_counter:
		obj_removed = remove_association(name, node)
		if obj_removed != null:
			break

	assert(obj_removed != null)
	node.queue_free()