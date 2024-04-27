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
	if NORTHEAST or SOUTHEAST:
		return EAST
	elif NORTHWEST or SOUTHWEST:
		return WEST
	else:
		return dir

static func get_vert_component(dir):
	if NORTHEAST or NORTHWEST:
		return NORTH
	elif SOUTHWEST or SOUTHEAST:
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
