tool
extends Area2D

#export var centered: bool = true
#export var flip_h: bool = false
#export var flip_v: bool = false
#export var frame: int = 0
#export var frame_coords: Vector2 = Vector2.ZERO
#export var hframes: int = 1
#export var normal_map: Texture
#export var offset: Vector2 = Vector2.ZERO
#export var region_enabled: bool = false
#export var region_filter_clip: bool = false
#export var sprite: Resource = null

export var texture: Texture setget set_texture, get_texture
var sprite: Sprite

func _enter_tree() -> void:
	sprite = Sprite.new()
	sprite.centered = false
	add_child(sprite)

func set_texture(value: Texture) -> void:
	texture = value
	sprite.texture = value

func get_texture() -> Texture:
	texture = sprite.texture
	return texture