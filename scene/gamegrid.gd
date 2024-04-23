extends TileMap

var player_scene = preload("res://scene/player.tscn")
var sword_scene = preload("res://scene/sword.tscn")
var item_ref_counter = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = player_scene.instance()
	var screen_size = get_viewport_rect().size
	add_child(player)
	player.spawn(position, position.y, screen_size.y - 32, position.x, screen_size.x - 32)
	player.connect("pick_up_item", self, "_on_player_pick_up_item")
	player.connect("pick_up_item", $"../infobar", "_on_player_pick_up_item")
	player.connect("used_item", $"../infobar", "_on_player_used_item")
	
	var sword = sword_scene.instance()
	add_child(sword)
	sword.position = Vector2(position.x + 32, position.y + 32)
	item_ref_counter["sword"] = 1

func _on_player_pick_up_item(item_name):
	item_ref_counter[item_name] -= 1
