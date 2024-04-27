extends TileMap

var player_ref
var player_scene = preload("res://scene/player.tscn")
var sword_scene = preload("res://scene/sword.tscn")
var zombie_scene = preload("res://scene/zombie.tscn")
var ref_counter = {"sword": 0, "zombie": 0}

const ITEM_SCORE = 5
const PASSIVE_SCORE = 1
const ZOMBIE_SCORE = 10

const MAX_ZOMBIES = 5
const VALID_DIST_FROM_PLAYER = 64
const ZOMBIE_SPAWN_PROB = 0.5

const MAX_ITEMS = 2

signal score_change(score_diff)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_up_player()

func set_up_player():
	player_ref = player_scene.instance()
	var screen_size = get_viewport_rect().size

	player_ref.connect("health_change", self, "_on_player_health_change")
	player_ref.connect("health_change", $"../infobar", "_on_player_health_change")
	player_ref.connect("pick_up_item", self, "_on_player_pick_up_item")
	player_ref.connect("pick_up_item", $"../infobar", "_on_player_pick_up_item")
	player_ref.connect("used_item", $"../infobar", "_on_player_used_item")
	
	add_child(player_ref)
	player_ref.spawn(position, position.y,
		screen_size.y - cell_size.y * 2, position.x, screen_size.x - cell_size.x)

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
			spawn_enemy(zombie_scene, get_spawn_pos())


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

func valid_spawn_pos(pos):
	var valid_pos = false
	
	if abs(pos.x - player_ref.position.x) >= VALID_DIST_FROM_PLAYER and \
		abs(pos.y - player_ref.position.y) >= VALID_DIST_FROM_PLAYER:
			var node_array = get_tree().get_nodes_in_group("interactable")
			var node_array_sz = node_array.size()
			var idx = 0
			valid_pos = true
			
			while valid_pos and idx < node_array_sz:
				valid_pos = node_array[idx].position != pos
				idx += 1
				
	return valid_pos

func spawn_enemy(scene, pos):
	var instance = scene.instance()
	instance.connect("enemy_destroyed", self, "_on_enemy_destroyed")
	add_child(instance)
	instance.spawn(pos, get_orient_facing_player(pos))
	ref_counter[instance.get_meta("type")] += 1

func _on_item_spawn_timer_timeout():
	if ref_counter["sword"] < MAX_ITEMS:
		spawn_item(sword_scene, get_spawn_pos())

func spawn_item(scene, pos):
	var instance = scene.instance()
	add_child(instance)
	instance.position = pos
	ref_counter[instance.get_meta("type")] += 1

func get_orient_facing_player(pos):
	var diff_x = pos.x - player_ref.position.x
	var diff_y = pos.y - player_ref.position.y
	var orient
	
	if abs(diff_x) < abs(diff_y):
		if diff_x >= 0:
			orient = Direction.SOUTH
		else:
			orient = Direction.NORTH
	else:
		if diff_y >= 0:
			orient = Direction.WEST
		else:
			orient = Direction.EAST
	
	return orient
