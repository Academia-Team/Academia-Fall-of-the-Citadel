class_name Enemy
extends InteractableObject

signal enemy_destroyed(enemy_type)
signal move_request(ref)

const MAX_ALLOWED_FAILED_MOVES = 10

var alive = true
var to_destroy = false
var move_fail_counter = 0
var type = "Zombie"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$CollisionBox.set_deferred("disabled", true)


func attack():
	alive = false
	$CollisionBox.set_deferred("disabled", true)
	emit_signal("enemy_destroyed", type)
	$CharacterSprite.show_hurt()
	$HurtSFX.play()
	$MoveTimer.stop()


func desired_positions(target_pos):
	var dir = Direction.get_dir_facing(target_pos, position)

	var component_directions = Direction.get_dir_components(dir)

	var possible_positions = []

	if alive:
		for direction in component_directions:
			possible_positions.append(Direction.translate_pos(position, direction, 32))

	return possible_positions


func destroy():
	hide()
	to_destroy = true

	if not $HurtSFX.playing:
		queue_free()


func is_shovable():
	return false


func move_to(pos):
	if alive:
		move_fail_counter = 0
		var diff_pos = pos - position
		position = pos
		$CharacterSprite.set_orient(Direction.rel_pos_to_dir(diff_pos))
		$WalkSFX.play()


func move_reject():
	move_fail_counter += 1

	if move_fail_counter >= MAX_ALLOWED_FAILED_MOVES:
		alive = false
		queue_free()


func spawn(pos, orient):
	position = pos
	$CharacterSprite.set_orient(orient)

	show()
	$CollisionBox.set_deferred("disabled", false)
	$SpawnSFX.play()
	$MoveTimer.start()


func _on_MoveTimer_timeout():
	if alive:
		emit_signal("move_request", self)


func _on_HurtSFX_finished():
	if to_destroy:
		destroy()
