extends Area2D
class_name Enemy

signal enemy_destroyed(enemy_type)
signal move_request(ref)

const MAX_ALLOWED_FAILED_MOVES = 10

var alive = true
var to_destroy = false
var move_fail_counter = 0
var type = "zombie"


func get_class():
	return "Enemy"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$collisionbox.set_deferred("disabled", true)


func attack():
	alive = false
	$collisionbox.set_deferred("disabled", true)
	emit_signal("enemy_destroyed", type)
	$CharacterSprite.show_hurt()
	$hurt_sfx.play()
	$move_timer.stop()


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

	if not $hurt_sfx.playing:
		queue_free()


func exists():
	return visible


func is_shovable():
	return false


func move_to(pos):
	if alive:
		move_fail_counter = 0
		var diff_pos = pos - position
		position = pos
		$CharacterSprite.set_orient(Direction.rel_pos_to_dir(diff_pos))
		$walk_sfx.play()


func move_reject():
	move_fail_counter += 1

	if move_fail_counter >= MAX_ALLOWED_FAILED_MOVES:
		alive = false
		queue_free()


func spawn(pos, orient):
	position = pos
	$CharacterSprite.set_orient(orient)

	show()
	$collisionbox.set_deferred("disabled", false)
	$spawn_sfx.play()
	$move_timer.start()


func _on_move_timer_timeout():
	if alive:
		emit_signal("move_request", self)


func _on_hurt_sfx_finished():
	if to_destroy:
		destroy()
