extends Area2D
class_name player

var direction
var held_weapon
var lives

signal pick_up_weapon(weapon_name)
signal used_weapon(weapon_name)

const SPEED = 200

func get_class():
	return "player"

func has_weapon():
	return (held_weapon != null)

func handle_action(delta):
	direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	if Input.is_action_pressed("move_down"):
		direction.y = 1
	if Input.is_action_just_pressed("action"):
		if has_weapon():
			emit_signal("used_weapon", held_weapon)
			held_weapon = null
		
	position += direction * SPEED * delta

func _process(delta):
	if lives <= 0:
		.hide()
		call_deferred("free")
	else:
		handle_action(delta)


# Called when the node enters the scene tree for the first time.
func _ready():
	held_weapon = null
	lives = 3


func _on_player_area_entered(area):
	var collisionCategory = area.get_class()
	if collisionCategory == 'weapon':
		if area.has_meta("type") and held_weapon == null:
			held_weapon = area.get_meta("type")
			emit_signal("pick_up_weapon", held_weapon)
	elif collisionCategory == 'enemy':
		if (lives > 0): lives = lives - 1
