extends Area2D

var direction
var held_weapon

signal pick_up_weapon(weapon_name)

const SPEED = 200

func has_weapon():
	return (held_weapon != null)

func _process(delta):
	direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	if Input.is_action_pressed("move_down"):
		direction.y = 1
	
	position += direction * SPEED * delta


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	held_weapon = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_player_area_entered(area):
	var collidedWith = area.name
	if collidedWith == 'sword':
		if held_weapon == null:
			held_weapon = collidedWith
			emit_signal("pick_up_weapon", held_weapon)
