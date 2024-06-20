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

export(Texture) var north_texture
export(Texture) var south_texture
export(Texture) var side_texture

export(Color) var heal_color = Color.pink
export(Color) var hurt_color = Color.tomato
export(float) var heal_length = 1.0
export(float) var hurt_length = 0.3
export(ValidOrientation) var orientation = Direction.SOUTH

var effect_timer
var initial_texture
onready var orig_self_modulate = self_modulate


func _init():
	._init()

	effect_timer = Timer.new()
	effect_timer.one_shot = true
	effect_timer.connect("timeout", self, "_on_effect_timeout")
	add_child(effect_timer)


# A hack due to the fact that when a CharacterSprite is placed, its texture will
# be overwritten. If _ready() is redefined, set_orient() will have to be manually
# called.
func _ready():
	set_orient(orientation)


func get_orient_texture(orient):
	orient = Direction.get_horz_component(orient)
	var target_texture
	match orient:
		Direction.NORTH:
			target_texture = north_texture
		Direction.SOUTH:
			target_texture = south_texture
		_:
			target_texture = side_texture

	return target_texture


func set_orient(orient):
	if orient != null:
		var old_orient = orientation
		var new_texture = get_orient_texture(orient)

		orient = Direction.get_horz_component(orient)
		flip_h = (orient == Direction.EAST)
		orientation = orient
		texture = new_texture

		if orient != old_orient:
			emit_signal("orientation_changed", old_orient, orient)


func show_heal(length = heal_length):
	_show_effect(length, heal_color)


func show_hurt(length = hurt_length):
	_show_effect(length, hurt_color)


func _show_effect(length, color):
	if not effect_timer.is_stopped():
		effect_timer.stop()
		effect_timer.signal("timeout")
		effect_timer.yield("timeout")

	effect_timer.wait_time = length

	orig_self_modulate = self_modulate
	self_modulate = color

	effect_timer.start()
	emit_signal("effect_show")


func _on_effect_timeout():
	self_modulate = orig_self_modulate
	emit_signal("effect_finish")
