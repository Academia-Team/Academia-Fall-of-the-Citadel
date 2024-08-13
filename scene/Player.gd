class_name Player
extends InteractableObject

signal health_change(lives)
signal move_request(dir)
signal pick_up_item(item_ref)
signal used_item(item_name)

const PLAYER_DEATH: Texture = preload("res://asset/pixelart_skull.png")
const START_LIVES: int = 3
const SWORD_SLASH: PackedScene = preload("res://scene/SwordAttack.tscn")

var held_item: Item = null

var _bounds: Dictionary = {
	Direction.NORTH: 0, Direction.SOUTH: 0, Direction.WEST: 0, Direction.EAST: 0
}
var _lives: int = 0
var _targets_to_destroy: Array = []

var _future_dir: int = Direction.NONE
var _immortal: bool = false
var _mid_use: bool = false


func get_lives() -> int:
	return _lives


func lives_lost() -> int:
	if _lives <= 0:
		return START_LIVES
	return START_LIVES - _lives


func _set_dir(dir) -> void:
	_future_dir = dir


func kill() -> void:
	while _lives > 0:
		if is_immortal():
			toggle_immortality()

		_hurt()
		yield($ImmunityTimer, "timeout")


func _pos_in_bounds(pos: Vector2) -> bool:
	return (
		pos.x >= _bounds.left
		&& pos.x <= _bounds.right
		&& pos.y >= _bounds.top
		&& pos.y <= _bounds.bottom
	)


func _handle_action() -> void:
	_handle_movement()
	if Input.is_action_just_pressed("action"):
		_use_item()


func _handle_movement() -> void:
	var desired_dir: int = Direction.NONE

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
		_set_dir(desired_dir)
	$CharacterSprite.set_orient(desired_dir)


func _use_item() -> void:
	if held_item != null and not _mid_use:
		match held_item.type:
			"Duck":
				_use_duck()
			"Health":
				_use_health()
			"Sword":
				_use_sword()
			_:
				_discard_item()
	else:
		$Reject.play()


func _use_sword() -> void:
	var orient: int = $CharacterSprite.get_orient()
	_targets_to_destroy = ($TargetTracker as TargetTracker).get_targets(orient)
	var slash_generated: bool = _generate_sword_slash(32)
	slash_generated = _generate_sword_slash(64) or slash_generated

	if slash_generated:
		for target in _targets_to_destroy:
			if target is Enemy:
				target.attack()

		_discard_item()
	else:
		$Reject.play()


func _generate_sword_slash(num_pixels_away: float) -> bool:
	var slash_anim: CanvasItem = null

	if _pos_in_bounds(
		Direction.translate_pos(position, $CharacterSprite.get_orient(), num_pixels_away)
	):
		slash_anim = SWORD_SLASH.instance()
		slash_anim.position = Direction.dir_to_rel_pos(
			$CharacterSprite.get_orient(), num_pixels_away
		)
		var slash_status: int = slash_anim.connect(
			"animation_finished", self, "_slash_anim_finished"
		)

		if slash_status == OK:
			add_child(slash_anim)
		else:
			printerr("Cannot generate sword slash.")
			slash_anim.free()
			slash_anim = null

	return slash_anim != null


func _use_duck() -> void:
	_mid_use = true

	var duck_sfx: AudioStreamPlayer = held_item.get_node("UseSFX")
	duck_sfx.play()
	yield(duck_sfx, "finished")
	_discard_item()


func _use_health() -> void:
	_mid_use = true

	if _lives < START_LIVES:
		_lives += 1
		var heal_sfx: AudioStreamPlayer = held_item.get_node("UseSFX")

		heal_sfx.play()
		$CharacterSprite.show_heal()
		emit_signal("health_change", _lives)
		yield(heal_sfx, "finished")
	else:
		var heal_fail_anim: AnimationPlayer = held_item.get_node("Fail")
		heal_fail_anim.play()
		yield(heal_fail_anim, "animation_finished")

	_discard_item()


func _discard_item() -> void:
	emit_signal("used_item", held_item.type)
	held_item.destroy()
	held_item = null
	_mid_use = false


func _process(_delta: float) -> void:
	if _lives > 0:
		if _future_dir != Direction.NONE and $MoveTimer.is_stopped():
			$MoveTimer.start()

		_handle_action()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	($TargetTracker as TargetTracker).disable()
	$CollisionBox.set_deferred("disabled", true)


func spawn(
	pos: Vector2, top_bound: float, bottom_bound: float, left_bound: float, right_bound: float
) -> void:
	$CharacterSprite.set_orient(Direction.SOUTH)
	position = pos
	_bounds.left = left_bound
	_bounds.right = right_bound
	_bounds.top = top_bound
	_bounds.bottom = bottom_bound

	held_item = null
	_future_dir = Direction.NONE
	_mid_use = false

	_lives = START_LIVES
	emit_signal("health_change", _lives)
	show()

	($TargetTracker as TargetTracker).enable()
	$CollisionBox.set_deferred("disabled", false)


func _hurt() -> void:
	if $ImmunityTimer.is_stopped() and not is_immortal():
		if _lives > 0:
			_lives -= 1
		emit_signal("health_change", _lives)
		$CharacterSprite.show_hurt()
		$HurtSFX.play()
		$ImmunityTimer.start()

		if _lives <= 0:
			$CollisionBox.set_deferred("disabled", true)
			($TargetTracker as TargetTracker).disable()


func move_to(pos: Vector2) -> void:
	position = pos
	$WalkSFX.play()


func move_reject() -> void:
	$Reject.play()


func _on_MoveTimer_timeout() -> void:
	if _future_dir != Direction.NONE:
		emit_signal("move_request", _future_dir)
		_future_dir = Direction.NONE


func _on_Player_area_entered(area: Area2D):
	if area is Item:
		if not held_item:
			held_item = area.acquire()
			emit_signal("pick_up_item", held_item.type)
	elif area is Enemy:
		_hurt()
		area.attack()
		area.destroy()


func _slash_anim_finished() -> void:
	for target_to_destroy in _targets_to_destroy:
		if target_to_destroy != null:
			target_to_destroy.destroy()

	_targets_to_destroy.clear()


func is_immortal() -> bool:
	return _immortal


func toggle_immortality() -> void:
	_immortal = not _immortal


func _on_CharacterSprite_effect_finish() -> void:
	if _lives <= 0:
		$CharacterSprite.texture = PLAYER_DEATH
