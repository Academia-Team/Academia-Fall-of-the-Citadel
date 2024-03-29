extends Area2D

var direction
var has_sword

signal pick_up_weapon(weapon_name)

const SPEED = 200

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
	has_sword = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_player_area_entered(area):
	var collidedWith = area.name
	if collidedWith == 'sword':
		has_sword = true
		emit_signal("pick_up_weapon", "sword")
