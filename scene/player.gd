extends Area2D
class_name player

var bounds = {Direction.NORTH: 0, Direction.SOUTH: 0, Direction.WEST: 0, Direction.EAST: 0}
var held_item
var lives
var targets = [null, null, null, null]
var target_to_destroy

const MOVE_QUEUE_SZ = 256
var move_queue

const NUM_DIRS = 4
const NUM_ORIENT = 4

signal health_change(lives)
signal pick_up_item(item_name)
signal used_item(item_name)

const SPEED = 200

func get_class():
	return "player"
	
func set_dir(dir):
	$move_timer.set_paused(true)
	
	var found_opposing_dir = false
	var opposing_dir_array = Direction.get_opposing_dirs(dir)
	var opposing_dir_sz = opposing_dir_array.size()
	var opposing_dir_idx = 0
	
	while not found_opposing_dir and opposing_dir_idx < opposing_dir_sz:
		if move_queue.contains(opposing_dir_array[opposing_dir_idx]):
			$move_timer.stop()
			move_queue.clear()
			$move_input_timer.start()
			found_opposing_dir = true
		
		opposing_dir_idx += 1
	
	if not found_opposing_dir and $move_input_timer.is_stopped():
		move_queue.queue(dir)
		$move_input_timer.start()
		
	$move_timer.set_paused(false)

func pos_in_bounds(pos):
	return pos.x >= bounds.left && pos.x <= bounds.right && \
		pos.y >= bounds.top && pos.y <= bounds.bottom

func handle_action():
	handle_movement()
	if Input.is_action_just_pressed("action"):
		use_item()

func handle_movement():
	var desired_dir = null
	
	if Input.is_action_pressed("move_up"):
		desired_dir = Direction.combine_dir(Direction.NORTH, desired_dir)
	if Input.is_action_pressed("move_down"):
		desired_dir = Direction.combine_dir(Direction.SOUTH, desired_dir)
	if Input.is_action_pressed("move_right"):
		desired_dir = Direction.combine_dir(Direction.EAST, desired_dir)
	if Input.is_action_pressed("move_left"):
		desired_dir = Direction.combine_dir(Direction.WEST, desired_dir)
	if Input.is_action_pressed("move_up_left"):
		desired_dir = Direction.combine_dir(Direction.NORTHWEST, desired_dir)
	if Input.is_action_pressed("move_up_right"):
		desired_dir = Direction.combine_dir(Direction.NORTHEAST, desired_dir)
	if Input.is_action_pressed("move_down_left"):
		desired_dir = Direction.combine_dir(Direction.SOUTHWEST, desired_dir)
	if Input.is_action_pressed("move_down_right"):
		desired_dir = Direction.combine_dir(Direction.SOUTHEAST, desired_dir)
	
	if desired_dir != null:
		if not Input.is_action_pressed("stay"):
			set_dir(desired_dir)
		$CharacterSprite.set_orient(desired_dir)

func use_item():
	if held_item:
		match held_item:
			"sword":
				use_sword()
		emit_signal("used_item", held_item)
		held_item = null

func use_sword():
	target_to_destroy = targets[$CharacterSprite.orientation]
			
	if target_to_destroy != null:
		target_to_destroy.attack()
		var slash_anim = load("res://scene/sword_attack.tscn").instance()
		slash_anim.position = Direction.dir_to_rel_pos($CharacterSprite.orientation, 32)
		slash_anim.connect("animation_finished", self, "_slash_anim_finished")
		add_child(slash_anim)

func _process(_delta):
	if lives > 0:
		if not move_queue.empty() and $move_timer.is_stopped():
			$move_timer.start()
			
		handle_action()


# Called when the node enters the scene tree for the first time.
func _ready():
	held_item = null
	lives = 3
	move_queue = Queue.new(MOVE_QUEUE_SZ)
	emit_signal("health_change", lives)
	
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
func spawn(pos, topBound, bottomBound, leftBound, rightBound):
	position = pos
	bounds.left = leftBound
	bounds.right = rightBound
	bounds.top = topBound
	bounds.bottom = bottomBound
	
	assert(position.x >= bounds.left && position.x <= bounds.right)
	assert(position.y >= bounds.top && position.y <= bounds.bottom)
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func handle_collision(obj):
	var collisionCategory = obj.get_class()
	if collisionCategory == "item":
		if not held_item:
			held_item = obj.acquire()
			emit_signal("pick_up_item", held_item)
	elif collisionCategory == 'enemy':
		hurt()
		obj.attack()
		obj.destroy()
		
func hurt():
	if (lives > 0): lives -= 1
	emit_signal("health_change", lives)
	$CharacterSprite.show_hurt()
	$hurt_sfx.play()
	
	if lives <= 0:
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)


func _on_move_timer_timeout():
	if not move_queue.empty():
		var dir = move_queue.dequeue()
		var future_pos = Direction.translate_pos(position, dir, 32)
		
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
			orient = Direction.EAST
		"left_collisionbox":
			orient = Direction.WEST
		"top_collisionbox":
			orient = Direction.NORTH
		"bottom_collisionbox":
			orient = Direction.SOUTH
		_:
			orient = -1
	
	return orient

func _slash_anim_finished():
	target_to_destroy.destroy()
