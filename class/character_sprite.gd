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
var initial_texture
onready var orig_self_modulate = self_modulate

signal orientation_changed(old_orient, new_orient)
signal hurt_show()
signal hurt_finish()

func _init():
	._init()
	
	hurt_timer = Timer.new()
	hurt_timer.one_shot = true
	hurt_timer.connect("timeout", self, "_on_hurt_timeout")
	add_child(hurt_timer)

# A hack due to the fact that when a character_sprite is placed, its texture will
# be overwritten. If _ready() is redefined, set_orient() will have to be manually
# called.
func _ready():
	set_orient(orientation)

func get_orient_texture(orient):
	orient = direction.get_horz_component(orient)
	var target_texture
	match orient:
		direction.NORTH:
			target_texture = north_texture
		direction.SOUTH:
			target_texture = south_texture
		_:
			target_texture = side_texture
	
	return target_texture

func set_orient(orient):
	var old_orient = orientation
	var new_texture = get_orient_texture(orient)
	
	orient = direction.get_horz_component(orient)
	flip_h = (orient == direction.WEST)
	orientation = orient
	texture = new_texture
	
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
