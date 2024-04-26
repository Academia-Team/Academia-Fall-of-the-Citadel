extends Area2D
class_name player

const queue = preload("res://class/queue.gd")

var bounds = {"top": 0, "bottom": 0, "left": 0, "right": 0}
var cur_orient
var future_dir
var held_item
var lives
var targets = [null, null, null, null]

const MOVE_QUEUE_SZ = 256
var move_queue

const NUM_DIRS = 4
const NUM_ORIENT = 4

enum DIRECTION {UP, DOWN, LEFT, RIGHT}
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

signal health_change(lives)
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
		match held_item:
			"sword":
				use_sword()
		emit_signal("used_item", held_item)
		held_item = null

func use_sword():
	var target_obj = targets[cur_orient]
			
	if target_obj != null:
		target_obj.attack()
		var slash_anim = load("res://scene/sword_attack.tscn").instance()
		slash_anim.position = target_obj.position
		add_child(slash_anim)

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
	emit_signal("health_change", lives)
	
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
		hurt()
		obj.attack()
		
func hurt():
	if (lives > 0): lives -= 1
	emit_signal("health_change", lives)
	$Sprite.self_modulate = Color.tomato
	$hurt_timer.start()


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


func _on_player_area_shape_entered(_area_rid, area, _area_shape_index, local_shape_index):
	var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
	
	if triggered_collisionbox.name == "collisionbox":
		handle_collision(area)
	elif area.get_class() == "enemy":
		var target_orient = orient_from_collision_box(triggered_collisionbox)
		
		while targets[target_orient] != null:
			yield(self, "area_shape_exited")
			
		targets[target_orient] = area


func _on_player_area_shape_exited(_area_rid, area, _area_shape_index, local_shape_index):
	if area != null:
		var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
		if triggered_collisionbox.name != "collisionbox" and area.get_class() == "enemy":
			var target_orient = orient_from_collision_box(triggered_collisionbox)
			targets[target_orient] = null

func orient_from_collision_box(collisionbox):
	var orient
	
	match collisionbox.name:
		"right_collisionbox":
			orient = ORIENTATION.EAST
		"left_collisionbox":
			orient = ORIENTATION.WEST
		"top_collisionbox":
			orient = ORIENTATION.NORTH
		"bottom_collisionbox":
			orient = ORIENTATION.SOUTH
		_:
			orient = -1
	
	return orient

func _on_hurt_timer_timeout():
	$Sprite.self_modulate = Color(1, 1, 1, 1)
