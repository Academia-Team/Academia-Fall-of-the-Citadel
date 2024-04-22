extends Area2D
class_name player

var bounds = {"top": 0, "bottom": 0, "left": 0, "right": 0}
var curOrient
var held_weapon
var lives


enum DIRECTION {UP, DOWN, LEFT, RIGHT}
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

signal pick_up_weapon(weapon_name)
signal used_weapon(weapon_name)

const SPEED = 200

func get_class():
	return "player"

func has_weapon():
	return (held_weapon != null)
	
func set_dir(dir, delta):
	var direction = Vector2.ZERO
	
	match dir:
		DIRECTION.UP:
			direction.y = -32
		DIRECTION.DOWN:
			direction.y = 32
		DIRECTION.LEFT:
			direction.x = -32
		DIRECTION.RIGHT:
			direction.x = 32
			
	position += direction.normalized() * SPEED * delta
	position.x = clamp(position.x, bounds.left, bounds.right)
	position.y = clamp(position.y, bounds.top, bounds.bottom)
	
func set_orient(orient):
	match orient:
		ORIENTATION.NORTH:
			$Sprite.set_texture(load("res://asset/Player_NORTH.png"))
		ORIENTATION.SOUTH:
			$Sprite.set_texture(load("res://asset/Player_SOUTH.png"))
		_:
			$Sprite.set_texture(load("res://asset/Player_SIDE.png"))
			
	$Sprite.flip_h = (orient == ORIENTATION.WEST)
	curOrient = orient

func handle_action(delta):
	if Input.is_action_pressed("move_right"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.RIGHT, delta)
		set_orient(ORIENTATION.EAST)
	if Input.is_action_pressed("move_left"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.LEFT, delta)
		set_orient(ORIENTATION.WEST)
	if Input.is_action_pressed("move_up"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.UP, delta)
		set_orient(ORIENTATION.NORTH)
	if Input.is_action_pressed("move_down"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.DOWN, delta)
		set_orient(ORIENTATION.SOUTH)
	if Input.is_action_just_pressed("action"):
		if has_weapon():
			emit_signal("used_weapon", held_weapon)
			held_weapon = null

func _process(delta):
	if lives <= 0:
		.hide()
		call_deferred("free")
	else:
		handle_action(delta)


# Called when the node enters the scene tree for the first time.
func _ready():
	held_weapon = null
	lives = 3
	curOrient = ORIENTATION.SOUTH
	hide()
	
func spawn(pos, topBound, bottomBound, leftBound, rightBound):
	position = pos
	bounds.left = leftBound
	bounds.right = rightBound
	bounds.top = topBound
	bounds.bottom = bottomBound
	show()


func _on_player_area_entered(area):
	var collisionCategory = area.get_class()
	if collisionCategory == 'weapon':
		if area.has_meta("type") and held_weapon == null:
			held_weapon = area.get_meta("type")
			emit_signal("pick_up_weapon", held_weapon)
	elif collisionCategory == 'enemy':
		if (lives > 0): lives = lives - 1
