class_name Direction
extends Reference

enum { NONE = 0, NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST }


static func get_opposing_dirs(dir: int) -> Array:
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


static func dir_to_rel_pos(dir: int, step: float = 32) -> Vector2:
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
		_:
			return Vector2.ZERO


static func get_horz_component(dir: int) -> int:
	if dir == NORTHEAST or dir == SOUTHEAST:
		return EAST
	if dir == NORTHWEST or dir == SOUTHWEST:
		return WEST
	return dir


static func get_vert_component(dir: int) -> int:
	if dir == NORTHEAST or dir == NORTHWEST:
		return NORTH
	if dir == SOUTHWEST or dir == SOUTHEAST:
		return SOUTH
	return dir


static func combine_dir(dir1: int, dir2: int) -> int:	
	if dir_opposites(dir1, dir2):
		return NONE
	
	if dir1 == NORTH or dir2 == NORTH:
		if dir2 == EAST or dir1 == EAST:
			return NORTHEAST
		elif dir2 == WEST or dir1 == WEST:
			return NORTHWEST

	if dir1 == SOUTH or dir2 == SOUTH:
		if dir2 == EAST or dir1 == EAST:
			return SOUTHEAST
		elif dir2 == WEST or dir1 == WEST:
			return SOUTHWEST
	
	if is_valid_dir(dir1):
		return dir1
	
	if is_valid_dir(dir2):
		return dir2
	
	return NONE


static func dir_opposites(dir1: int, dir2: int) -> bool:
	for dir_opposite in get_opposing_dirs(dir1):
		if dir2 == dir_opposite:
			return true
	return false


static func get_dir_components(dir: int) -> Array:
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
			if is_valid_dir(dir):
				return [dir]
			return []


static func translate_pos(pos: Vector2, dir: int, step: float = 32) -> Vector2:
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


static func get_cardinal_dir_facing(pos_to_face: Vector2, pos: Vector2) -> int:
	if (pos - pos_to_face) != Vector2(0, 0):
		if abs(pos.x - pos_to_face.x) < abs(pos.y - pos_to_face.y) or (pos.y - pos_to_face.y) == 0:
			if (pos.x - pos_to_face.x) >= 0:
				return WEST
			return EAST

		if (pos.y - pos_to_face.y) >= 0:
			return NORTH
		return SOUTH

	return NONE


static func get_dir_facing(pos_to_face: Vector2, pos: Vector2) -> int:
	return rel_pos_to_dir(pos_to_face - pos)


static func rel_pos_to_dir(pos: Vector2) -> int:
	return combine_dir(_get_horz_dir_from_pos(pos), _get_vert_dir_from_pos(pos))


static func _get_horz_dir_from_pos(pos: Vector2) -> int:
	if pos.x > 0:
		return EAST
	if pos.x < 0:
		return WEST
	return NONE


static func _get_vert_dir_from_pos(pos: Vector2) -> int:
	if pos.y > 0:
		return SOUTH
	if pos.y < 0:
		return NORTH
	return NONE


static func is_cardinal_dir(dir: int) -> bool:
	return dir == NORTH or dir == SOUTH or dir == EAST or dir == WEST


static func is_horz(dir: int) -> bool:
	return dir == EAST or dir == WEST


static func is_vert(dir: int) -> bool:
	return dir == NORTH or dir == SOUTH


static func is_valid_dir(dir: int) -> bool:
	return is_cardinal_dir(dir) or is_horz(dir) or is_vert(dir)
