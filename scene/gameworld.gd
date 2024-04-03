extends Node2D

var zombie_scene = preload("res://scene/zombie.tscn")
var player_scene = preload("res://scene/player.tscn")
var sword_scene = preload("res://scene/sword.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = player_scene.instance()
	var sword1 = sword_scene.instance()
	var sword2 = sword_scene.instance()
	var zombie1 = zombie_scene.instance()
	var zombie2 = zombie_scene.instance()
	var zombie3 = zombie_scene.instance()
	
	add_child(player)
	player.position = Vector2(0,0)
	add_child(sword1)
	sword1.position = Vector2(96, 96)
	add_child(sword2)
	sword2.position = Vector2(96, 0)
	add_child(zombie1)
	zombie1.position = Vector2(64,0)
	add_child(zombie2)
	zombie2.position = Vector2(32,32)
	add_child((zombie3))
	zombie3.position = Vector2(64,64)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
