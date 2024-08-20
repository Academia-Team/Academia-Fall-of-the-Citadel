class_name GameGrid
extends TileWorld

signal game_over
signal started

const PASSIVE_SCORE := 1

const MAX_ZOMBIES := 5
const VALID_DIST_FROM_PLAYER := 64.0
const ZOMBIE_SPAWN_PROB := 0.6

const MAX_SWORDS := 2

const MAX_HEALTH_POTIONS := 1
const BASE_HEALTH_SPAWN_PROB := 0.1
const HEALTH_SPAWN_PROB_PER_LIFE := 0.1

const INITIAL_SPAWN_PROB := 0.3

const DUCK_SCENE: PackedScene = preload("res://scene/Duck.tscn")
const HEALTH_SCENE: PackedScene = preload("res://scene/Health.tscn")
const SWORD_SCENE: PackedScene = preload("res://scene/Sword.tscn")
const ZOMBIE_SCENE: PackedScene = preload("res://scene/Zombie.tscn")

const INVALID_VECTOR := Vector2(-1, -1)

var ref_counter := {}
var info_ref: InfoBar = null
var started := false

var enemy_rng := RandomNumberGenerator.new()
var item_rng := RandomNumberGenerator.new()


func start(info_obj: InfoBar) -> void:
	info_ref = info_obj
	ref_counter = {}
	$Music.play()
	$PassiveTimer.start()
	$ZombieSpawnTimer.start()
	$ItemSpawnTimer.start()

	if info_obj.get_mode() == "Duck":
		$DuckTimer.start()

	set_up_rng()
	$Player.spawn(self, Vector2.ZERO)
	spawn_initial_env()
	emit_signal("started")
	started = true


func set_up_rng() -> void:
	enemy_rng.set_seed(info_ref.get_seed())
	item_rng.set_seed(info_ref.get_seed())
	seed(info_ref.get_seed())


func spawn_initial_env() -> void:
	spawn_initial_items()
	spawn_initial_enemies()


func spawn_initial_items() -> void:
	for _counter in range(MAX_SWORDS):
		if item_rng.randf() < INITIAL_SPAWN_PROB:
			spawn_item(SWORD_SCENE, get_spawn_pos())


func spawn_initial_enemies() -> void:
	for _counter in range(MAX_ZOMBIES):
		if enemy_rng.randf() < INITIAL_SPAWN_PROB:
			spawn_enemy(ZOMBIE_SCENE, get_spawn_pos())


func cleanup() -> void:
	for obj in get_tree().get_nodes_in_group(InteractableObject.GROUP):
		if obj is Player:
			obj.set_existence(false)
		else:
			obj.queue_free()


func _process(_delta: float) -> void:
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


func handle_stop_spawn_options() -> void:
	if Input.is_action_pressed("cheat_item"):
		$ItemSpawnTimer.paused = not $ItemSpawnTimer.paused
		info_ref.set_timed_status("Item spawn toggled.")
	elif Input.is_action_pressed("cheat_enemy"):
		for timer in get_tree().get_nodes_in_group("enemy_spawner"):
			timer.paused = not timer.paused

		info_ref.set_timed_status("Enemy spawn toggled.")
	elif Input.is_action_pressed("cheat_zombie"):
		$ZombieSpawnTimer.paused = not $ZombieSpawnTimer.paused
		info_ref.set_timed_status("Zombie spawn toggled.")
	elif Input.is_action_pressed("cheat_stop_spawn"):
		for timer in get_tree().get_nodes_in_group("spawner"):
			timer.paused = not timer.paused

		info_ref.set_timed_status("All spawners toggled.")
	else:
		info_ref.set_timed_status("Nothing toggled.")


func _on_Player_pick_up_item(item_ref: Item) -> void:
	if ref_counter.has(item_ref.type):
		ref_counter[item_ref.type] -= 1
	else:
		printerr("Item %s is not tracked." % item_ref.type)

	info_ref.update_score(item_ref.points)
	info_ref.set_status(item_ref.type)


func _on_Player_used_item(_item_name: String) -> void:
	info_ref.reset_status()


func _on_passive_timer_timeout() -> void:
	info_ref.update_score(PASSIVE_SCORE)


func _on_Enemy_destroyed(ref: Enemy) -> void:
	info_ref.update_score(ref.points)


func _on_Zombie_tree_exiting() -> void:
	ref_counter["Zombie"] -= 1


func _on_Player_health_change(lives: int) -> void:
	if not started:
		yield(self, "started")

	info_ref.display_lives(lives)

	if lives <= 0:
		stop()
		info_ref.reset_status()
		info_ref.set_status("Goodbye Forever!")
		$GameOverSFX.play()


func stop() -> void:
	started = false
	$Music.stop()
	$PassiveTimer.stop()
	$ZombieSpawnTimer.stop()
	$ItemSpawnTimer.stop()
	$DuckTimer.stop()


func _on_Zombie_spawn_timer_timeout() -> void:
	if ref_counter.get("Zombie", 0) < MAX_ZOMBIES:
		if enemy_rng.randf() < ZOMBIE_SPAWN_PROB:
			spawn_enemy(ZOMBIE_SCENE, get_spawn_pos())


func get_spawn_pos() -> Vector2:
	var available_cells: Array = get_used_cells()
	var num_available_cells: int = available_cells.size()
	var spawn_pos := INVALID_VECTOR
	var proposed_spawn_pos: Vector2

	while spawn_pos == INVALID_VECTOR and num_available_cells > 0:
		var rand_cell_idx := randi() % num_available_cells
		proposed_spawn_pos = map_to_world(available_cells[rand_cell_idx])

		if valid_spawn_pos(proposed_spawn_pos):
			spawn_pos = proposed_spawn_pos
		else:
			available_cells.remove(rand_cell_idx)
			num_available_cells -= 1

	return spawn_pos


func valid_spawn_pos(pos: Vector2) -> bool:
	var valid_pos := false

	if (
		(
			abs(pos.x - $Player.position.x) >= VALID_DIST_FROM_PLAYER
			or abs(pos.y - $Player.position.y) >= VALID_DIST_FROM_PLAYER
		)
		and pos_in_world(pos)
	):
		valid_pos = get_interactable_obj_at_pos(pos) == null

	return valid_pos


func spawn_enemy(scene: PackedScene, pos: Vector2) -> void:
	if pos != INVALID_VECTOR:
		var instance: Enemy = scene.instance()

		var destroyed_status: int = instance.connect("enemy_destroyed", self, "_on_Enemy_destroyed")
		var exiting_status: int = instance.connect(
			"tree_exiting", self, "_on_%s_tree_exiting" % instance.type
		)
		var move_status: int = instance.connect("move_request", self, "_on_Enemy_move_request")

		if destroyed_status == OK and exiting_status == OK and move_status == OK:
			add_child(instance)
			var orient_facing_player: int = Direction.get_cardinal_dir_facing($Player.position, pos)
			instance.spawn(pos, orient_facing_player)
			ref_counter[instance.type] = ref_counter.get(instance.type, 0) + 1
		else:
			printerr("Failed to properly set up enemy. Nothing will be spawned.")


func _on_item_spawn_timer_timeout() -> void:
	if item_rng.randf() < _get_health_probability():
		if ref_counter.get("Health", 0) < MAX_HEALTH_POTIONS:
			spawn_item(HEALTH_SCENE, get_spawn_pos())
	else:
		if ref_counter.get("Sword", 0) < MAX_SWORDS:
			spawn_item(SWORD_SCENE, get_spawn_pos())


func spawn_item(scene: PackedScene, pos: Vector2) -> void:
	if pos != INVALID_VECTOR:
		var instance: Item = scene.instance()
		add_child(instance)
		instance.spawn(self, pos)
		ref_counter[instance.type] = ref_counter.get(instance.type, 0) + 1


func _on_Enemy_move_request(ref: Enemy) -> void:
	var desired_positions: Array = ref.desired_positions($Player.position)
	var moved := false

	for pos in desired_positions:
		# Want to ensure that all the enemies aren't moving on top of each other. If that is happening,
		# just have the enemy lose its turn.
		var obj_at_pos: InteractableObject = get_interactable_obj_at_pos(pos)

		if obj_at_pos == null:
			ref.move_to(pos)
			moved = true
			break
		elif obj_at_pos.is_shovable():
			var dir_to_shove: int = Direction.get_cardinal_dir_facing(pos, ref.position)
			if move_shovable_obj(obj_at_pos, dir_to_shove):
				moved = true
				break

		if not moved:
			ref.move_reject()


func move_shovable_obj(ref: InteractableObject, shove_dir: int) -> bool:
	var dest_pos: Vector2 = Direction.translate_pos(ref.position, shove_dir, 32)
	var success := false

	if (
		get_interactable_obj_at_pos(dest_pos) == null
		and pos_in_world(dest_pos)
		and ($Player.held_item == null or $Player.position != dest_pos)
	):
		success = ref.shove_to(dest_pos)

	return success


func _on_gameover_sfx_finished() -> void:
	emit_signal("game_over")


func _on_Player_move_request(dir: int) -> void:
	if $Player.get_lives() > 0:
		var future_pos: Vector2 = Direction.translate_pos($Player.position, dir, 32)

		if pos_in_world(future_pos):
			var interactable_obj: InteractableObject = get_interactable_obj_at_pos(future_pos)
			if $Player.held_item == null or interactable_obj == null or interactable_obj is Enemy:
				$Player.move_to(future_pos)
			elif not move_shovable_obj(interactable_obj, dir):
				$Player.move_reject()
		else:
			$Player.move_reject()


func _on_DuckTimer_timeout() -> void:
	spawn_item(DUCK_SCENE, get_spawn_pos())


# Returns the first non-player object that exists at the given position or null if no
# object exists.
func get_interactable_obj_at_pos(pos: Vector2) -> InteractableObject:
	for obj in get_tree().get_nodes_in_group(InteractableObject.GROUP):
		if not obj is Player and obj.position == pos and obj.exists:
			return obj

	return null


func _get_health_probability() -> int:
	return BASE_HEALTH_SPAWN_PROB + HEALTH_SPAWN_PROB_PER_LIFE * $Player.lives_lost()
