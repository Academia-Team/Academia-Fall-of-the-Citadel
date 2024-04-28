extends Area2D
class_name enemy

signal enemy_destroyed(enemy_type)
signal move_request(ref)

func get_class():
	return "enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "zombie")
	
	hide()
	$collisionbox.set_deferred("monitoring", false)
	$collisionbox.set_deferred("monitorable", false)

func attack():
	$collisionbox.set_deferred("monitoring", false)
	$collisionbox.set_deferred("monitorable", false)
	emit_signal("enemy_destroyed", get_meta("type"))
	$CharacterSprite.show_hurt()
	
func desired_positions(target_pos):
	var dir = Direction.get_dir_facing(target_pos, position)
	
	var component_directions = Direction.get_dir_components(dir)
	
	var possible_positions = []
	
	for direction in component_directions:
		possible_positions.append(Direction.translate_pos(position, direction, 32))
	
	return possible_positions

func move(pos):
	var diff_pos = pos - position
	position = pos
	$CharacterSprite.set_orient(Direction.rel_pos_to_dir(diff_pos))

func spawn(pos, orient):
	position = pos
	$CharacterSprite.set_orient(orient)
	
	show()
	$collisionbox.set_deferred("monitoring", true)
	$collisionbox.set_deferred("monitorable", true)


func _on_move_timer_timeout():
	emit_signal("move_request", self)
