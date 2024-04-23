extends Area2D
class_name player

const queue = preload("res://class/queue.gd")

var bounds = {"top": 0, "bottom": 0, "left": 0, "right": 0}
var cur_orient
var future_dir
var held_item
var lives
var targets = {"top": null, "bottom": null, "left": null, "right": null}

const MOVE_QUEUE_SZ = 256
var move_queue

enum DIRECTION {UP, DOWN, LEFT, RIGHT}
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

signal pick_up_item(item_name)
signal used_item(item_name)

const SPEED = 200

func get_class():
	return "player"
	
func set_dir(dir):
	$move_timer.set_paused(true)
	
	if move_queue.contains(get_opposing_dir(dir)):
		$move_timer.stop()
		move_queue.clear()
		$move_input_timer.start()
	elif $move_input_timer.is_stopped():
		move_queue.queue(dir)
		$move_input_timer.start()
		
	$move_timer.set_paused(false)

func pos_in_bounds(pos):
	return pos.x >= bounds.left && pos.x <= bounds.right && \
		pos.y >= bounds.top && pos.y <= bounds.bottom
	
func set_orient(orient):
	match orient:
		ORIENTATION.NORTH:
			$Sprite.set_texture(load("res://asset/Player_NORTH.png"))
		ORIENTATION.SOUTH:
			$Sprite.set_texture(load("res://asset/Player_SOUTH.png"))
		_:
			$Sprite.set_texture(load("res://asset/Player_SIDE.png"))
			
	$Sprite.flip_h = (orient == ORIENTATION.WEST)
	cur_orient = orient

func handle_action():
	if Input.is_action_pressed("move_right"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.RIGHT)
		set_orient(ORIENTATION.EAST)
	if Input.is_action_pressed("move_left"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.LEFT)
		set_orient(ORIENTATION.WEST)
	if Input.is_action_pressed("move_up"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.UP)
		set_orient(ORIENTATION.NORTH)
	if Input.is_action_pressed("move_down"):
		if not Input.is_action_pressed("stay"): set_dir(DIRECTION.DOWN)
		set_orient(ORIENTATION.SOUTH)
	if Input.is_action_just_pressed("action"):
		use_item()
			
func use_item():
	if held_item:
		emit_signal("used_item", held_item)
		held_item = null

func _process(_delta):
	if lives <= 0:
		.hide()
		call_deferred("free")
	else:
		if not move_queue.empty() and $move_timer.is_stopped():
			$move_timer.start()
			
		handle_action()


# Called when the node enters the scene tree for the first time.
func _ready():
	held_item = null
	lives = 3
	cur_orient = ORIENTATION.SOUTH
	move_queue = Queue.new(MOVE_QUEUE_SZ)
	
	hide()
	
func spawn(pos, topBound, bottomBound, leftBound, rightBound):
	position = pos
	bounds.left = leftBound
	bounds.right = rightBound
	bounds.top = topBound
	bounds.bottom = bottomBound
	
	assert(position.x >= bounds.left && position.x <= bounds.right)
	assert(position.y >= bounds.top && position.y <= bounds.bottom)
	
	show()

func get_opposing_dir(dir):
	var opposing_dir
	match dir:
		DIRECTION.UP:
			opposing_dir = DIRECTION.DOWN
		DIRECTION.DOWN:
			opposing_dir = DIRECTION.UP
		DIRECTION.LEFT:
			opposing_dir = DIRECTION.RIGHT
		DIRECTION.RIGHT:
			opposing_dir = DIRECTION.LEFT
	
	return opposing_dir

func handle_collision(obj):
	var collisionCategory = obj.get_class()
	if collisionCategory == "item":
		if not held_item:
			held_item = obj.acquire()
			emit_signal("pick_up_item", held_item)
	elif collisionCategory == 'enemy':
		if (lives > 0): lives = lives - 1
		obj.attack()


func _on_move_timer_timeout():
	if not move_queue.empty():
		var dir = move_queue.dequeue()
		var future_pos = position
		
		match dir:
			DIRECTION.UP:
				future_pos.y -= 32
			DIRECTION.DOWN:
				future_pos.y += 32
			DIRECTION.LEFT:
				future_pos.x -= 32
			DIRECTION.RIGHT:
				future_pos.x += 32
		
		if pos_in_bounds(future_pos):
			position = future_pos
		else:
			move_queue.clear()


func _on_player_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
	
	if triggered_collisionbox.name == "collisionbox":
		handle_collision(area)
	elif area.get_class() == "Enemy":
		match triggered_collisionbox.name:
			"right_collisionbox":
				targets["right"] = area
			"left_collisionbox":
				targets["left"] = area
			"top_collisionbox":
				targets["top"] = area
			"bottom_collisionbox":
				targets["bottom"] = area


func _on_player_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
	match triggered_collisionbox.name:
		"right_collisionbox":
			targets["right"] = null
		"left_collisionbox":
			targets["left"] = null
		"top_collisionbox":
			targets["top"] = null
		"bottom_collisionbox":
			targets["bottom"] = null
