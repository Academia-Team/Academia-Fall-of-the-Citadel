tool
extends Sprite

signal orientation_changed(old_orient, new_orient)

enum ValidOrientation {
	NORTH = Direction.NORTH,
	SOUTH = Direction.SOUTH,
	EAST = Direction.EAST,
	WEST = Direction.WEST
}

export var north_texture: Texture setget set_north_texture
export var south_texture: Texture setget set_south_texture
export var side_texture: Texture setget set_side_texture

export(ValidOrientation) var orientation := Direction.SOUTH setget set_orient, get_orient
export var faces_east := false setget set_faces_east


func _enter_tree() -> void:
	centered = false


func _is_valid_orient(orient: int) -> bool:
	return (
		orient == ValidOrientation.NORTH
		or orient == ValidOrientation.SOUTH
		or orient == ValidOrientation.EAST
		or orient == ValidOrientation.WEST
	)


func get_orient_texture(orient: int) -> Texture:
	orient = Direction.get_horz_component(orient)
	var target_texture: Texture
	match orient:
		Direction.NORTH:
			target_texture = north_texture
		Direction.SOUTH:
			target_texture = south_texture
		_:
			target_texture = side_texture

	return target_texture


func set_orient(orient: int) -> void:
	if _is_valid_orient(orient):
		var old_orient: int = orientation
		var new_texture: Texture = get_orient_texture(orient)

		orient = Direction.get_horz_component(orient)
		flip_h = (
			faces_east and orient == Direction.WEST
			or not faces_east and orient == Direction.EAST
		)
		orientation = orient
		texture = new_texture

		if orient != old_orient:
			emit_signal("orientation_changed", old_orient, orient)


func get_orient() -> int:
	return orientation


func set_north_texture(new_texture: Texture) -> void:
	north_texture = new_texture
	set_orient(orientation)


func set_south_texture(new_texture: Texture) -> void:
	south_texture = new_texture
	set_orient(orientation)


func set_side_texture(new_texture: Texture) -> void:
	side_texture = new_texture
	set_orient(orientation)


func set_faces_east(value: bool) -> void:
	faces_east = value
	set_orient(orientation)
