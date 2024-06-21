extends Area2D
class_name Player

signal move_request(dir)

var bounds = {Direction.NORTH: 0, Direction.SOUTH: 0, Direction.WEST: 0, Direction.EAST: 0}
var held_item = null
var lives = 0
var targets = [[], [], [], []]
var targets_to_destroy = []

var future_dir = null
var immortal = false

const NUM_DIRS = 4
const NUM_ORIENT = 4
const START_LIVES = 3

signal health_change(lives)
signal pick_up_item(item_name)
signal used_item(item_name)

const SPEED = 200


func get_class():
	return "Player"


func exists():
	return visible


func set_dir(dir):
	$MoveTimer.set_paused(true)
	future_dir = dir
	$MoveTimer.set_paused(false)


func kill():
	while lives > 0:
		if is_immortal():
			toggle_immortality()

		hurt()
		yield($ImmunityTimer, "timeout")


func pos_in_bounds(pos):
	return (
		pos.x >= bounds.left
		&& pos.x <= bounds.right
		&& pos.y >= bounds.top
		&& pos.y <= bounds.bottom
	)


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

	if not Input.is_action_pressed("stay"):
		set_dir(desired_dir)
	$CharacterSprite.set_orient(desired_dir)


func use_item():
	if held_item != null:
		match held_item.type:
			"Sword":
				use_sword()
			"Duck":
				use_duck()
			"Health":
				use_health()
			_:
				discard_item()
	else:
		$Reject.play()


func use_sword():
	targets_to_destroy = targets[$CharacterSprite.orientation].duplicate(true)
	var slash_generated = _generate_sword_slash(32)
	slash_generated = _generate_sword_slash(64) or slash_generated

	if slash_generated:
		for target_to_destroy in targets_to_destroy:
			if target_to_destroy != null:
				target_to_destroy.attack()

		discard_item()
	else:
		$Reject.play()


func _generate_sword_slash(num_pixels_away):
	var slash_anim = null

	if pos_in_bounds(
		Direction.translate_pos(position, $CharacterSprite.orientation, num_pixels_away)
	):
		slash_anim = load("res://scene/SwordAttack.tscn").instance()
		slash_anim.position = Direction.dir_to_rel_pos(
			$CharacterSprite.orientation, num_pixels_away
		)
		slash_anim.connect("animation_finished", self, "_slash_anim_finished")
		add_child(slash_anim)

	return slash_anim


func use_duck():
	var duck_sfx = held_item.get_node("UseSFX")
	duck_sfx.play()
	yield(duck_sfx, "finished")
	discard_item()


func use_health():
	if lives < START_LIVES:
		lives += 1
		var heal_sfx = held_item.get_node("UseSFX")

		heal_sfx.play()
		$CharacterSprite.show_heal()
		emit_signal("health_change", lives)
		yield(heal_sfx, "finished")
	else:
		var heal_fail_sfx = held_item.get_node("FailSFX")
		heal_fail_sfx.play()
		yield(heal_fail_sfx, "finished")

	discard_item()


func discard_item():
	emit_signal("used_item", held_item.type)
	held_item.destroy()
	held_item = null


func _process(_delta):
	if lives > 0:
		if future_dir != null and $MoveTimer.is_stopped():
			$MoveTimer.start()

		handle_action()


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$CollisionBox.set_deferred("disabled", true)
	$RightCollisionBox.set_deferred("disabled", true)
	$Left_CollisionBox.set_deferred("disabled", true)
	$Top_CollisionBox.set_deferred("disabled", true)
	$Bottom_CollisionBox.set_deferred("disabled", true)


func spawn(pos, topBound, bottomBound, leftBound, rightBound):
	position = pos
	bounds.left = leftBound
	bounds.right = rightBound
	bounds.top = topBound
	bounds.bottom = bottomBound

	held_item = null
	future_dir = null

	lives = START_LIVES
	emit_signal("health_change", lives)

	assert(position.x >= bounds.left && position.x <= bounds.right)
	assert(position.y >= bounds.top && position.y <= bounds.bottom)
	show()

	$CollisionBox.set_deferred("disabled", false)
	$RightCollisionBox.set_deferred("disabled", false)
	$LeftCollisionBox.set_deferred("disabled", false)
	$TopCollisionBox.set_deferred("disabled", false)
	$BottomCollisionBox.set_deferred("disabled", false)


func handle_collision(obj):
	var collisionCategory = obj.get_class()
	if collisionCategory == "Item":
		if not held_item:
			held_item = obj.acquire()
			emit_signal("pick_up_item", held_item.type)
	elif collisionCategory == "Enemy":
		hurt()
		obj.attack()
		obj.destroy()


func hurt():
	if $ImmunityTimer.is_stopped() and not is_immortal():
		if lives > 0:
			lives -= 1
		emit_signal("health_change", lives)
		$CharacterSprite.show_hurt()
		$HurtSFX.play()
		$ImmunityTimer.start()

		if lives <= 0:
			$CollisionBox.set_deferred("disabled", true)
			$RightCollisionBox.set_deferred("disabled", true)
			$LeftCollisionBox.set_deferred("disabled", true)
			$TopCollisionBox.set_deferred("disabled", true)
			$BottomCollisionBox.set_deferred("disabled", true)


func move_to(pos):
	position = pos
	$WalkSFX.play()


func move_reject():
	$Reject.play()


func _on_move_timer_timeout():
	if future_dir != null:
		emit_signal("move_request", future_dir)
		future_dir = null


func _on_Player_area_shape_entered(_area_rid, area, _area_shape_index, local_shape_index):
	var triggered_collisionbox = shape_owner_get_owner(local_shape_index)

	if triggered_collisionbox.name == "collisionbox":
		handle_collision(area)
	elif area.get_class() == "Enemy":
		var target_orient = orient_from_collision_box(triggered_collisionbox)

		targets[target_orient].append(area)


func _on_Player_area_shape_exited(_area_rid, area, _area_shape_index, local_shape_index):
	if area != null:
		var triggered_collisionbox = shape_owner_get_owner(local_shape_index)
		if triggered_collisionbox.name != "collisionbox" and area.get_class() == "Enemy":
			var target_orient = orient_from_collision_box(triggered_collisionbox)
			targets[target_orient].erase(area)


func orient_from_collision_box(collisionbox):
	var orient

	match collisionbox.name:
		"RightCollisionBox":
			orient = Direction.EAST
		"LeftCollisionBox":
			orient = Direction.WEST
		"TopCollisionBox":
			orient = Direction.NORTH
		"BottomCollisionBox":
			orient = Direction.SOUTH
		_:
			orient = -1

	return orient


func _slash_anim_finished():
	for target_to_destroy in targets_to_destroy:
		if target_to_destroy != null:
			target_to_destroy.destroy()

	targets_to_destroy.clear()


func is_immortal():
	return immortal


func toggle_immortality():
	immortal = not immortal
