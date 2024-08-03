class_name Detector
extends CollisionShape2D

enum ValidOrientation {
	NORTH = Direction.NORTH,
	SOUTH = Direction.SOUTH,
	EAST = Direction.EAST,
	WEST = Direction.WEST,
	NORTHEAST = Direction.NORTHEAST,
	NORTHWEST = Direction.NORTHWEST,
	SOUTHEAST = Direction.SOUTHEAST,
	SOUTHWEST = Direction.SOUTHWEST
}

export(ValidOrientation) var orientation: int = Direction.NORTH
