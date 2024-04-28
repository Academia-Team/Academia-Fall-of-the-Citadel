extends Reference
class_name Direction

enum {NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST}

static func get_opposing_dirs(dir):
	match dir:
		NORTH:
			return [SOUTH]
		SOUTH:
			return [NORTH]
		EAST:
			return [WEST]
		WEST:
			return [EAST]
		NORTHEAST:
			return [SOUTH, WEST]
		NORTHWEST:
			return [SOUTH, EAST]
		SOUTHEAST:
			return [NORTH, WEST]
		SOUTHWEST:
			return [NORTH, EAST]
		_:
			return []

static func dir_to_rel_pos(dir, step):
	match dir:
		NORTH:
			return Vector2(0, -step)
		SOUTH:
			return Vector2(0, step)
		EAST:
			return Vector2(step, 0)
		WEST:
			return Vector2(-step, 0)
		NORTHEAST:
			return Vector2(step, -step)
		NORTHWEST:
			return Vector2(-step, -step)
		SOUTHEAST:
			return Vector2(step, step)
		SOUTHWEST:
			return Vector2(-step, step)

static func get_horz_component(dir):
	if dir == NORTHEAST or dir == SOUTHEAST:
		return EAST
	elif dir == NORTHWEST or dir == SOUTHWEST:
		return WEST
	else:
		return dir

static func get_vert_component(dir):
	if dir == NORTHEAST or dir == NORTHWEST:
		return NORTH
	elif dir == SOUTHWEST or dir == SOUTHEAST:
		return SOUTH
	else:
		return dir

static func combine_dir(dir1, dir2):
	if dir1 == null:
		return dir2
	elif dir2 == null:
		return dir1
	elif dir_opposites(dir1, dir2):
		return null
	elif dir1 != dir2:
		if dir1 == NORTH:
			if dir2 == EAST:
				return NORTHEAST
			else:
				return NORTHWEST
		elif dir1 == SOUTH:
			if dir2 == EAST:
				return SOUTHEAST
			else:
				return SOUTHWEST
		else:
			return combine_dir(dir2, dir1)
	else:
		return dir1

static func dir_opposites(dir1, dir2):
	for dir_opposite in get_opposing_dirs(dir1):
		if dir2 == dir_opposite:
			return true
	return false

static func get_dir_components(dir):
	match dir:
		NORTHEAST:
			return [NORTH, EAST]
		NORTHWEST:
			return [NORTH, WEST]
		SOUTHEAST:
			return [SOUTH, EAST]
		SOUTHWEST:
			return [SOUTH, WEST]
		_:
			return [dir]

static func translate_pos(pos, dir, step):
	for dir_component in get_dir_components(dir):
		match dir_component:
			NORTH:
				pos.y -= step
			SOUTH:
				pos.y += step
			WEST:
				pos.x -= step
			EAST:
				pos.x += step
	return pos

static func get_cardinal_dir_facing(pos_to_face, pos):
	if (pos - pos_to_face) != Vector2(0, 0):
		if abs(pos.x - pos_to_face.x) < abs(pos.y - pos_to_face.y) or (pos.y - pos_to_face.y) == 0:
			if (pos.x - pos_to_face.x) >= 0:
				return WEST
			else:
				return EAST
		else:
			if (pos.y - pos_to_face.y) >= 0:
				return NORTH
			else:
				return SOUTH
	else:
		return null

static func get_dir_facing(pos_to_face, pos):
	return rel_pos_to_dir(pos_to_face - pos)

static func rel_pos_to_dir(pos):
	return combine_dir(_get_horz_dir_from_pos(pos), _get_vert_dir_from_pos(pos))

static func _get_horz_dir_from_pos(pos):
	if pos.x > 0:
		return EAST
	elif pos.x < 0:
		return WEST
	else:
		return null

static func _get_vert_dir_from_pos(pos):
	if pos.y > 0:
		return SOUTH
	elif pos.y < 0:
		return NORTH
	else:
		return null
