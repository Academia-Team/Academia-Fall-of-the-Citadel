class_name Enemy
extends InteractableObject

signal enemy_destroyed(enemy_ref)
signal move_request(ref)

const MAX_ALLOWED_FAILED_MOVES := 10

var _move_fail_counter := 0


func _ready() -> void:
	set_existence(false)


func damage() -> void:
	set_existence(false)
	set_visible(true)
	emit_signal("enemy_destroyed", self)
	$CharacterSprite.show_hurt()
	$HurtSFX.play()
	$MoveTimer.stop()


func desired_positions(target_pos: Vector2) -> Array:
	var dir: int = Direction.get_dir_facing(target_pos, position)

	var component_directions: Array = Direction.get_dir_components(dir)

	var possible_positions := []

	if exists:
		for direction in component_directions:
			possible_positions.append(Direction.translate_pos(position, direction, 32))

	return possible_positions


func destroy() -> void:
	set_existence(false)

	if not $HurtSFX.playing:
		queue_free()


func move_to(pos: Vector2) -> void:
	if exists:
		_move_fail_counter = 0
		var diff_pos := pos - position
		position = pos
		$CharacterSprite.set_orient(Direction.rel_pos_to_dir(diff_pos))
		$WalkSFX.play()


func move_reject() -> void:
	_move_fail_counter += 1

	if _move_fail_counter >= MAX_ALLOWED_FAILED_MOVES:
		destroy()


func spawn(pos: Vector2, orient: int = Direction.SOUTH) -> void:
	position = pos
	$CharacterSprite.set_orient(orient)

	set_existence(true)
	$SpawnSFX.play()
	$MoveTimer.start()


func _on_MoveTimer_timeout() -> void:
	if exists:
		emit_signal("move_request", self)


func _on_HurtSFX_finished() -> void:
	destroy()
