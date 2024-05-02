extends Area2D
class_name player

var bounds = {Direction.NORTH: 0, Direction.SOUTH: 0, Direction.WEST: 0, Direction.EAST: 0}
var held_item
var lives
var targets = [[], [], [], []]
var targets_to_destroy = []

var future_dir

const NUM_DIRS = 4
const NUM_ORIENT = 4

signal health_change(lives)
signal pick_up_item(item_name)
signal used_item(item_name)

const SPEED = 200

func get_class():
	return "player"
	
func exists():
	return visible
	
func set_dir(dir):
	$move_timer.set_paused(true)
	future_dir = dir
	$move_timer.set_paused(false)

func kill():
	lives = 1
	hurt()

func pos_in_bounds(pos):
	return pos.x >= bounds.left && pos.x <= bounds.right && \
		pos.y >= bounds.top && pos.y <= bounds.bottom

func handle_action():
	handle_movement()
	if Input.is_action_just_pressed("action"):
		use_item()
	if OS.is_debug_build():
		if Input.is_action_just_pressed("suicide"):
			kill()

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
	
	if not Input.is_action_pressed("stay"):
		set_dir(desired_dir)
	$CharacterSprite.set_orient(desired_dir)

func use_item():
	if held_item:
		match held_item:
			"sword":
				use_sword()
			_:
				$forbidden_sfx.play()

func use_sword():
	targets_to_destroy = targets[$CharacterSprite.orientation].duplicate(true)
	var slash_generated = _generate_sword_slash(32)
	slash_generated = _generate_sword_slash(64) or slash_generated
	
	if slash_generated:
		for target_to_destroy in targets_to_destroy:
			if target_to_destroy != null:
				target_to_destroy.attack()
		
		emit_signal("used_item", "sword")
		held_item = null
	else:
		$forbidden_sfx.play()

func _generate_sword_slash(num_pixels_away):
	var slash_anim = null
	
	if pos_in_bounds(Direction.translate_pos(position, $CharacterSprite.orientation, num_pixels_away)):
		slash_anim = load("res://scene/sword_attack.tscn").instance()
		slash_anim.position = Direction.dir_to_rel_pos($CharacterSprite.orientation, num_pixels_away)
		slash_anim.connect("animation_finished", self, "_slash_anim_finished")
		add_child(slash_anim)
	
	return slash_anim

func _process(_delta):
	if lives > 0:
		if future_dir != null and $move_timer.is_stopped():
			$move_timer.start()
			
		handle_action()


# Called when the node enters the scene tree for the first time.
func _ready():
	held_item = null
	lives = 3
	future_dir = null
	emit_signal("health_change", lives)
	
	hide()
	$collisionbox.set_deferred("disabled", true)
	$right_collisionbox.set_deferred("disabled", true)
	$left_collisionbox.set_deferred("disabled", true)
	$top_collisionbox.set_deferred("disabled", true)
	$bottom_collisionbox.set_deferred("disabled", true)
	
func spawn(pos, topBound, bottomBound, leftBound, rightBound):
	position = pos
	bounds.left = leftBound
	bounds.right = rightBound
	bounds.top = topBound
	bounds.bottom = bottomBound
	
	assert(position.x >= bounds.left && position.x <= bounds.right)
	assert(position.y >= bounds.top && position.y <= bounds.bottom)
	show()
	
	$collisionbox.set_deferred("disabled", false)
	$right_collisionbox.set_deferred("disabled", false)
	$left_collisionbox.set_deferred("disabled", false)
	$top_collisionbox.set_deferred("disabled", false)
	$bottom_collisionbox.set_deferred("disabled", false)

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
	if $immunity_timer.is_stopped():
		if (lives > 0): lives -= 1
		emit_signal("health_change", lives)
		$CharacterSprite.show_hurt()
		$hurt_sfx.play()
		$immunity_timer.start()
		
		if lives <= 0:
			$collisionbox.set_deferred("disabled", true)
			$right_collisionbox.set_deferred("disabled", true)
			$left_collisionbox.set_deferred("disabled", true)
			$top_collisionbox.set_deferred("disabled", true)
			$bottom_collisionbox.set_deferred("disabled", true)


func _on_move_timer_timeout():
	if future_dir != null and lives > 0:
		var future_pos = Direction.translate_pos(position, future_dir, 32)
		future_dir = null
		
		if pos_in_bounds(future_pos):
			position = future_pos
		else:
			$forbidden_sfx.play()

func _on_player_area_shape_entered(_area_rid, area, _area_shape_index, local_shape_index):
	var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
	
	if triggered_collisionbox.name == "collisionbox":
		handle_collision(area)
	elif area.get_class() == "enemy":
		var target_orient = orient_from_collision_box(triggered_collisionbox)
			
		targets[target_orient].append(area)


func _on_player_area_shape_exited(_area_rid, area, _area_shape_index, local_shape_index):
	if area != null:
		var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
		if triggered_collisionbox.name != "collisionbox" and area.get_class() == "enemy":
			var target_orient = orient_from_collision_box(triggered_collisionbox)
			targets[target_orient].erase(area)

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
	for target_to_destroy in targets_to_destroy:
		if target_to_destroy != null:
			target_to_destroy.destroy()
	
	targets_to_destroy.clear()
