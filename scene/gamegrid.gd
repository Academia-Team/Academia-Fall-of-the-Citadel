extends TileMap

var player_ref
var player_scene = preload("res://scene/player.tscn")
var sword_scene = preload("res://scene/sword.tscn")
var zombie_scene = preload("res://scene/zombie.tscn")
var ref_counter = {}

const ITEM_SCORE = 5
const PASSIVE_SCORE = 1
const ZOMBIE_SCORE = 10

const MAX_ZOMBIES = 5
const VALID_DIST_FROM_PLAYER = 64
const ZOMBIE_SPAWN_PROB = 0.5

signal score_change(score_diff)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	player_ref = player_scene.instance()
	var screen_size = get_viewport_rect().size

	player_ref.connect("health_change", self, "_on_player_health_change")
	player_ref.connect("health_change", $"../infobar", "_on_player_health_change")
	player_ref.connect("pick_up_item", self, "_on_player_pick_up_item")
	player_ref.connect("pick_up_item", $"../infobar", "_on_player_pick_up_item")
	player_ref.connect("used_item", $"../infobar", "_on_player_used_item")
	
	add_child(player_ref)
	player_ref.spawn(position, position.y, screen_size.y - 32, position.x, screen_size.x - 32)
	
	var sword = sword_scene.instance()
	add_child(sword)
	sword.position = Vector2(position.x + 32, position.y + 32)
	ref_counter["sword"] = 1
	
	ref_counter["zombie"] = 0

func _on_player_pick_up_item(item_name):
	ref_counter[item_name] -= 1
	emit_signal("score_change", ITEM_SCORE)


func _on_passive_timer_timeout():
	emit_signal("score_change", PASSIVE_SCORE)

func _on_enemy_destroyed(enemy_type):
	match enemy_type:
		"zombie":
			ref_counter["zombie"] -= 1
			emit_signal("score_change", ZOMBIE_SCORE)

func _on_player_health_change(lives):
	if lives <= 0:
		var gameover = load("res://scene/gameover.tscn").instance()
		get_parent().add_child(gameover)
		gameover.set_info_src($"../infobar")
		call_deferred("free")

func _on_zombie_spawn_timer_timeout():
	if ref_counter["zombie"] < MAX_ZOMBIES:
		if randf() <= ZOMBIE_SPAWN_PROB:
			print(get_spawn_pos())


func get_spawn_pos():
	var available_cells = get_used_cells()
	var num_cells = available_cells.size()
	var spawn_pos
	var got_valid_pos = false
	
	while not got_valid_pos:
		var rand_cell_idx = randi() % num_cells
		spawn_pos = to_global(map_to_world(available_cells[rand_cell_idx]))
		
		if valid_spawn_pos(spawn_pos):
			got_valid_pos = true
			
	return spawn_pos

func spawn(scene):
	var available_cells = get_used_cells()
	var num_cells = available_cells.size()
	var placed_obj = false
	
	while not placed_obj:
		var rand_cell_idx = randi() % num_cells
		var target_pos = available_cells[rand_cell_idx]
		
		if valid_spawn_pos(target_pos):
			var instance = scene.instance()
			instance.connect("enemy_destroyed", self, "_on_enemy_destroyed")
			add_child(instance)
			instance.position = target_pos
			ref_counter[instance.get_meta("type")] += 1
			placed_obj = true

func valid_spawn_pos(pos):
	return abs(pos.x - player_ref.position.x) >= VALID_DIST_FROM_PLAYER and \
		abs(pos.y - player_ref.position.y) >= VALID_DIST_FROM_PLAYER
