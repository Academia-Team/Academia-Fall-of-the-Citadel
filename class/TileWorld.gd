# Adds helper methods to a TileMap to make it easier to create a game world.

class_name TileWorld
extends TileMap


func pos_in_world(pos: Vector2) -> bool:
	return get_cellv(world_to_map(pos)) != INVALID_CELL
