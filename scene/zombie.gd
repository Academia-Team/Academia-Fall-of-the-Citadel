extends Area2D
class_name enemy

signal enemy_destroyed(enemy_type)
signal move_request(ref)

var alive
var to_destroy

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	alive = true
	to_destroy = false
	set_meta("type", "zombie")
	
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func attack():
	alive = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	emit_signal("enemy_destroyed", get_meta("type"))
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

func move(pos):
	if alive:
		var diff_pos = pos - position
		position = pos
		$CharacterSprite.set_orient(Direction.rel_pos_to_dir(diff_pos))

func spawn(pos, orient):
	position = pos
	$CharacterSprite.set_orient(orient)
	
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	$spawn_sfx.play()
	$move_timer.start()


func _on_move_timer_timeout():
	if alive:
		emit_signal("move_request", self)

func _on_hurt_sfx_finished():
	if to_destroy:
		destroy()
