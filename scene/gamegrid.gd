extends TileMap

var player_scene = preload("res://scene/player.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = player_scene.instance()
	var screen_size = get_viewport_rect().size
	add_child(player)
	player.spawn(position, position.y, screen_size.y - 32, position.x, screen_size.x - 32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
