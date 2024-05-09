extends TileMap

var sword_scene = preload("res://scene/sword.tscn")
var zombie_scene = preload("res://scene/zombie.tscn")
var ref_counter = {"sword": 0, "zombie": 0}
var info_ref = null
var started = false

const ITEM_SCORE = 5
const PASSIVE_SCORE = 1
const ZOMBIE_SCORE = 10

const MAX_ZOMBIES = 5
const VALID_DIST_FROM_PLAYER = 64
const ZOMBIE_SPAWN_PROB = 0.5

const MAX_ITEMS = 2

signal game_over()
signal started()

func start(info_obj):
	info_ref = info_obj
	seed(info_obj.get_seed())
	set_up_player()
	emit_signal("started")
	started = true

func set_up_player():
	var screen_size = get_viewport_rect().size

	$player.spawn(Vector2(0, 0), 0,
		screen_size.y - cell_size.y * 2, 0, screen_size.x - cell_size.x)

func _on_player_pick_up_item(item_name):
	ref_counter[item_name] -= 1
	info_ref.incr_score(ITEM_SCORE)
	info_ref.set_status(item_name)

func _on_player_used_item(_item_name):
	info_ref.reset_status()


func _on_passive_timer_timeout():
	info_ref.incr_score(PASSIVE_SCORE)

func _on_enemy_destroyed(enemy_type):
	match enemy_type:
		"zombie":
			ref_counter["zombie"] -= 1
			info_ref.incr_score(ZOMBIE_SCORE)

func _on_player_health_change(lives):
	if not started:
		yield(self, "started")
	
	info_ref.set_lives(lives)
	
	if lives <= 0:
		$music.stop()
		$passive_timer.stop()
		$zombie_spawn_timer.stop()
		$item_spawn_timer.stop()
		set_process(false)
		$gameover_sfx.play()

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
		spawn_pos = map_to_world(available_cells[rand_cell_idx])
		
		if valid_spawn_pos(spawn_pos):
			got_valid_pos = true
			
	return spawn_pos

func valid_spawn_pos(pos):
	var valid_pos = false
	
	if abs(pos.x - $player.position.x) >= VALID_DIST_FROM_PLAYER and \
		abs(pos.y - $player.position.y) >= VALID_DIST_FROM_PLAYER:
			valid_pos = get_interactable_obj_at_pos(pos) == null
				
	return valid_pos

func get_interactable_obj_at_pos(pos):
	var interactable_obj = null
	
	var node_array = get_tree().get_nodes_in_group("interactable")
	var node_array_sz = node_array.size()
	var idx = 0
	
	while interactable_obj == null and idx < node_array_sz:
		if node_array[idx].exists():
			interactable_obj = node_array[idx]
		idx += 1

func spawn_enemy(scene, pos):
	var instance = scene.instance()
	instance.connect("enemy_destroyed", self, "_on_enemy_destroyed")
	instance.connect("move_request", self, "_on_enemy_move_request")
	add_child(instance)
	var orient_facing_player = Direction.get_cardinal_dir_facing($player.position, pos)
	instance.spawn(pos, orient_facing_player)
	ref_counter[instance.get_meta("type")] += 1

func _on_item_spawn_timer_timeout():
	if ref_counter["sword"] < MAX_ITEMS:
		spawn_item(sword_scene, get_spawn_pos())

func spawn_item(scene, pos):
	var instance = scene.instance()
	add_child(instance)
	instance.position = pos
	ref_counter[instance.get_meta("type")] += 1

func _on_enemy_move_request(ref):
	var desired_positions = ref.desired_positions($player.position)
	
	for pos in desired_positions:
		# Want to ensure that all the enemies aren't moving on top of each other. If that is happening,
		# just have the enemy lose its turn.
		var obj_at_pos = get_interactable_obj_at_pos(pos)
		
		if obj_at_pos == null:
			ref.move(pos)
			break
		elif obj_at_pos.is_shovable():
			var dir_to_shove = Direction.get_cardinal_dir_facing(pos, ref.position)
			if move_shovable_obj(obj_at_pos, dir_to_shove):
				break

func move_shovable_obj(ref, shove_dir):
	var dest_pos = Direction.translate_pos(ref.position, shove_dir, 32)
	var success = false
	
	if get_interactable_obj_at_pos(dest_pos) == null:
		ref.shove_to(dest_pos)
		success = true
		
	return success


func _on_gameover_sfx_finished():
	emit_signal("game_over")
