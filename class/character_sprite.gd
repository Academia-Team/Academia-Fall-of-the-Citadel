extends Sprite
class_name CharacterSprite

const direction = preload("res://class/direction.gd")

export(Texture) var north_texture
export(Texture) var south_texture
export(Texture) var side_texture

enum valid_orientation {NORTH = direction.NORTH, SOUTH = direction.SOUTH,
	EAST = direction.EAST, WEST = direction.WEST}

export(Color) var hurt_color = Color.tomato
export(float) var hurt_length = 0.3
export(valid_orientation) var orientation = direction.SOUTH

var hurt_timer
onready var orig_self_modulate = self_modulate

signal orientation_changed(old_orient, new_orient)
signal hurt_show()
signal hurt_finish()

func _init():
	._init()
	set_orient(orientation)
	
	hurt_timer = Timer.new()
	hurt_timer.one_shot = true
	hurt_timer.connect("timeout", self, "_on_hurt_timeout")
	add_child(hurt_timer)

func set_orient(orient):
	var old_orient = orientation
	orient = direction.get_horz_component(orient)
	match orient:
		direction.NORTH:
			set_texture(north_texture)
		direction.SOUTH:
			set_texture(south_texture)
		_:
			set_texture(side_texture)
			
	flip_h = (orient == direction.WEST)
	orientation = orient
	
	if orient != old_orient:
		emit_signal("orientation_changed", old_orient, orient)

func show_hurt(length = hurt_length):
	hurt_timer.wait_time = length
	
	orig_self_modulate = self_modulate
	self_modulate = hurt_color
	
	hurt_timer.start()
	emit_signal("hurt_show")

func _on_hurt_timeout():
	self_modulate = orig_self_modulate
	emit_signal("hurt_finish")
