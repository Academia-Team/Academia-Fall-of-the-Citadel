class_name CharacterSprite
extends Sprite

signal orientation_changed(old_orient, new_orient)
signal effect_show
signal effect_finish

enum ValidOrientation {
	NORTH = Direction.NORTH,
	SOUTH = Direction.SOUTH,
	EAST = Direction.EAST,
	WEST = Direction.WEST
}

export var north_texture: Texture
export var south_texture: Texture
export var side_texture: Texture

export var heal_color: Color = Color.pink
export var hurt_color: Color = Color.tomato
export var heal_length: float = 1.0
export var hurt_length: float = 0.3
export(ValidOrientation) var orientation: int = Direction.SOUTH

var effect_timer: Timer
var initial_texture: Texture
onready var orig_self_modulate: Color = self_modulate


func _init() -> void:
	._init()

	effect_timer = Timer.new()
	effect_timer.one_shot = true
	var connect_status: int = effect_timer.connect("timeout", self, "_on_effect_timeout")

	if connect_status != OK:
		printerr("Timer connect failure: Status effects will be displayed indefinitely.")

	add_child(effect_timer)


# A hack due to the fact that when a CharacterSprite is placed, its texture will
# be overwritten. If _ready() is redefined, set_orient() will have to be manually
# called.
func _ready() -> void:
	set_orient(orientation)


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


func _is_valid_orient(orient: int) -> bool:
	return (
		orient == ValidOrientation.NORTH
		or orient == ValidOrientation.SOUTH
		or orient == ValidOrientation.EAST
		or orient == ValidOrientation.WEST
	)


func set_orient(orient: int) -> void:
	if _is_valid_orient(orient):
		var old_orient: int = orientation
		var new_texture: Texture = get_orient_texture(orient)

		orient = Direction.get_horz_component(orient)
		flip_h = (orient == Direction.EAST)
		orientation = orient
		texture = new_texture

		if orient != old_orient:
			emit_signal("orientation_changed", old_orient, orient)


func show_heal(length: float = heal_length) -> void:
	_show_effect(length, heal_color)


func show_hurt(length: float = hurt_length) -> void:
	_show_effect(length, hurt_color)


func _show_effect(length: float, color: Color) -> void:
	if not effect_timer.is_stopped():
		effect_timer.stop()
		effect_timer.signal("timeout")
		effect_timer.yield("timeout")

	effect_timer.wait_time = length

	orig_self_modulate = self_modulate
	self_modulate = color

	effect_timer.start()
	emit_signal("effect_show")


func _on_effect_timeout() -> void:
	self_modulate = orig_self_modulate
	emit_signal("effect_finish")
