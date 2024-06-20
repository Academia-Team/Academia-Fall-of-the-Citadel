class_name Group
extends Reference


# Returns the first object that exists at the given position or null if no object exists.
static func get_obj_at_pos(scene_tree, group, pos):
	for obj in scene_tree.get_nodes_in_group(group):
		if obj.position == pos:
			if obj.has_method("exists") and obj.exists() or not obj.has_method("exists"):
				return obj

	return null
