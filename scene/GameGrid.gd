extends TileMap

var health_scene = preload("res://scene/health.tscn")
var sword_scene = preload("res://scene/sword.tscn")
var zombie_scene = preload("res://scene/zombie.tscn")
var ref_counter = {}
var info_ref = null
var started = false

const ITEM_SCORE = 5
const PASSIVE_SCORE = 1
const ZOMBIE_SCORE = 10

const MAX_ZOMBIES = 5
const VALID_DIST_FROM_PLAYER = 64
const ZOMBIE_SPAWN_PROB = 0.5

const MAX_ITEMS = 3
const HEALTH_SPAWN_PROB = 0.3

signal game_over
signal started


func start(info_obj):
	info_ref = info_obj
	ref_counter = {}
	$Music.play()
	$PassiveTimer.start()
	$ZombieSpawnTimer.start()
	$ItemSpawnTimer.start()

	if info_obj.get_mode() == "Duck":
		$DuckTimer.start()

	seed(info_obj.get_seed())
	set_up_player()
	emit_signal("started")
	started = true


func restart():
	start(info_ref)


func cleanup():
	for interactable in get_tree().get_nodes_in_group("interactable"):
		interactable.queue_free()


func _process(_delta):
	if started and info_ref.is_cheat_enabled():
		if Input.is_action_just_pressed("cheat_suicide"):
			$Player.kill()
		elif Input.is_action_just_pressed("cheat_god"):
			$Player.toggle_immortality()

			if $Player.is_immortal():
				info_ref.set_timed_status("Feeling Powerful?")
			else:
				info_ref.set_timed_status("Death waits for you.")
		elif Input.is_action_just_pressed("cheat_stop_spawn"):
			yield(get_tree().create_timer(1), "timeout")
			handle_stop_spawn_options()


func handle_stop_spawn_options():
	if Input.is_action_pressed("cheat_item"):
		$ItemSpawnTimer.paused = not $ItemSpawnTimer.paused
		info_ref.set_timed_status("Item spawn toggled.")
	elif Input.is_action_pressed("cheat_enemy"):
		for timer in get_tree().get_nodes_in_group("enemy_spawner"):
			timer.paused = not timer.paused

		info_ref.set_timed_status("Enemy spawn toggled.")
	elif Input.is_action_pressed("cheat_zombie"):
		$zombie_spawn_timer.paused = not $zombie_spawn_timer.paused
		info_ref.set_timed_status("Zombie spawn toggled.")
	elif Input.is_action_pressed("cheat_stop_spawn"):
		for timer in get_tree().get_nodes_in_group("spawner"):
			timer.paused = not timer.paused

		info_ref.set_timed_status("All spawners toggled.")
	else:
		info_ref.set_timed_status("Nothing toggled.")


func set_up_player():
	var screen_size = get_viewport_rect().size

	$Player.spawn(Vector2(0, 0), 0, screen_size.y - cell_size.y * 2, 0, screen_size.x - cell_size.x)


func _on_Player_pick_up_item(item_name):
	if item_name != "duck":
		ref_counter["item"] -= 1
	else:
		ref_counter["duck"] -= 1

	info_ref.incr_score(ITEM_SCORE)
	info_ref.set_timed_status("Press space or first button to use item")
	info_ref.set_status(item_name)


func _on_Player_used_item(_item_name):
	info_ref.reset_status()


func _on_passive_timer_timeout():
	info_ref.incr_score(PASSIVE_SCORE)


func _on_enemy_destroyed(enemy_type):
	match enemy_type:
		"zombie":
			info_ref.incr_score(ZOMBIE_SCORE)


func _on_zombie_tree_exiting():
	ref_counter["zombie"] -= 1


func _on_Player_health_change(lives):
	if not started:
		yield(self, "started")

	info_ref.set_lives(lives)

	if lives <= 0:
		started = false
		$Music.stop()
		$PassiveTimer.stop()
		$ZombieSpawnTimer.stop()
		$ItemSpawnTimer.stop()
		$GameOverSFX.play()


func _on_zombie_spawn_timer_timeout():
	if ref_counter.get("zombie", 0) < MAX_ZOMBIES:
		if randf() <= ZOMBIE_SPAWN_PROB:
			spawn_enemy(zombie_scene, get_spawn_pos())


func get_spawn_pos():
	var available_cells = get_used_cells()
	var num_available_cells = available_cells.size()
	var spawn_pos = null
	var proposed_spawn_pos

	while spawn_pos == null and num_available_cells > 0:
		var rand_cell_idx = randi() % num_available_cells
		proposed_spawn_pos = map_to_world(available_cells[rand_cell_idx])

		if valid_spawn_pos(proposed_spawn_pos):
			spawn_pos = proposed_spawn_pos
		else:
			available_cells.remove(rand_cell_idx)
			num_available_cells -= 1

	return spawn_pos


func valid_spawn_pos(pos):
	var valid_pos = false

	if (
		(
			abs(pos.x - $Player.position.x) >= VALID_DIST_FROM_PLAYER
			or abs(pos.y - $Player.position.y) >= VALID_DIST_FROM_PLAYER
		)
		and get_cellv(world_to_map(pos)) != INVALID_CELL
	):
		valid_pos = Group.get_obj_at_pos(get_tree(), "interactable", pos) == null

	return valid_pos


func spawn_enemy(scene, pos):
	var instance = scene.instance()
	instance.connect("enemy_destroyed", self, "_on_enemy_destroyed")
	instance.connect("tree_exiting", self, "_on_%s_tree_exiting" % instance.type)
	instance.connect("move_request", self, "_on_enemy_move_request")
	add_child(instance)
	var orient_facing_player = Direction.get_cardinal_dir_facing($Player.position, pos)
	instance.spawn(pos, orient_facing_player)
	ref_counter[instance.type] = ref_counter.get(instance.type, 0) + 1


func _on_item_spawn_timer_timeout():
	if ref_counter.get("item", 0) < MAX_ITEMS:
		if randf() <= HEALTH_SPAWN_PROB:
			spawn_item(health_scene, get_spawn_pos())
		else:
			spawn_item(sword_scene, get_spawn_pos())


func spawn_item(scene, pos, ref_name = "item"):
	if scene != null and pos != null:
		var instance = scene.instance()
		add_child(instance)
		instance.position = pos
		ref_counter[ref_name] = ref_counter.get(ref_name, 0) + 1


func _on_enemy_move_request(ref):
	var desired_positions = ref.desired_positions($Player.position)
	var moved = false

	for pos in desired_positions:
		# Want to ensure that all the enemies aren't moving on top of each other. If that is happening,
		# just have the enemy lose its turn.
		var obj_at_pos = Group.get_obj_at_pos(get_tree(), "interactable", pos)

		if obj_at_pos == null:
			ref.move_to(pos)
			moved = true
			break
		elif obj_at_pos.is_shovable():
			var dir_to_shove = Direction.get_cardinal_dir_facing(pos, ref.position)
			if move_shovable_obj(obj_at_pos, dir_to_shove):
				moved = true
				break

		if not moved:
			ref.move_reject()


func move_shovable_obj(ref, shove_dir):
	var dest_pos = Direction.translate_pos(ref.position, shove_dir, 32)
	var success = false

	if (
		Group.get_obj_at_pos(get_tree(), "interactable", dest_pos) == null
		and get_cellv(world_to_map(dest_pos)) != INVALID_CELL
		and ($Player.held_item == null or $Player.position != dest_pos)
	):
		if ref.is_shovable():
			ref.shove_to(dest_pos)
			success = true

	return success


func _on_gameover_sfx_finished():
	emit_signal("game_over")


func _on_Player_move_request(dir):
	if $Player.lives > 0:
		var future_pos = Direction.translate_pos($Player.position, dir, 32)

		if get_cellv(world_to_map(future_pos)) != INVALID_CELL:
			var interactable_obj = Group.get_obj_at_pos(get_tree(), "interactable", future_pos)
			if (
				$Player.held_item == null
				or interactable_obj == null
				or interactable_obj.get_class() == "enemy"
			):
				$Player.move_to(future_pos)
			elif not move_shovable_obj(interactable_obj, dir):
				$Player.move_reject()
		else:
			$Player.move_reject()


func _on_duck_timer_timeout():
	spawn_item(load("res://scene/duck.tscn"), get_spawn_pos(), "duck")
