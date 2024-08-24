class_name Player
extends InteractableObject

signal health_change(lives)
signal move_request(dir)
signal pick_up_item(item_ref)
signal used_item(item_name)

const MOVEMENT_MSG := "Hold movement controls for %.1f second(s) to move."
const MOVEMENT_MSG_TIME := 5.0

const ITEM_PICKUP_MSG := "Press space or first button to use item"
const ITEM_PICKUP_MSG_TIME := 3.0

const START_LIVES := 3

var events: Dictionary
var gameworld: TileWorld
var held_item: Item
var lives: int setget set_lives, get_lives

var _future_dir: int setget _set_dir
var _immortal: bool


func get_orient() -> int:
	return $CharacterSprite.get_orient()


func get_lives() -> int:
	return lives


func set_lives(value: int) -> void:
	if lives > 0 and lives != value and value >= 0 and value <= START_LIVES:
		if value < lives:
			_damaged(value)
		else:
			_healed()

		lives = value
		emit_signal("health_change", value)


func _set_initial_lives(value: int = START_LIVES) -> void:
	lives = value
	emit_signal("health_change", value)


func _damaged(remaining_lives: int) -> void:
	if $ImmunityTimer.is_stopped() and not is_immortal():
		if remaining_lives >= 0:
			$CharacterSprite.show_hurt()
			$HurtSFX.play()
			$ImmunityTimer.start()
		if remaining_lives == 0:
			set_existence(false)
			set_visible(true)
			$CharacterSprite.show_death()


func _healed() -> void:
	$CharacterSprite.show_heal()


func lives_lost() -> int:
	if lives <= 0:
		return START_LIVES
	return START_LIVES - lives


func damage(damage_amount: int = 1) -> void:
	if damage_amount > 0:
		var new_lives := lives - damage_amount
		if new_lives < 0:
			new_lives = 0
		set_lives(new_lives)


func heal(heal_amount: int = 1) -> void:
	if heal_amount > 0:
		var new_lives := lives + heal_amount
		if new_lives > START_LIVES:
			new_lives = START_LIVES
		set_lives(new_lives)


func _set_dir(dir: int) -> void:
	_future_dir = dir


func kill() -> void:
	while exists and lives > 0:
		if is_immortal():
			toggle_immortality()

		damage()
		yield($ImmunityTimer, "timeout")


func _handle_action() -> void:
	_handle_movement()
	if Input.is_action_just_pressed("action"):
		_use_item()


func _handle_movement() -> void:
	var desired_dir := Direction.NONE

	if Input.is_action_pressed("move_up"):
		desired_dir = Direction.combine_dir(Direction.NORTH, desired_dir)
	if Input.is_action_pressed("move_down"):
		desired_dir = Direction.combine_dir(Direction.SOUTH, desired_dir)
	if Input.is_action_pressed("move_right"):
		desired_dir = Direction.combine_dir(Direction.EAST, desired_dir)
	if Input.is_action_pressed("move_left"):
		desired_dir = Direction.combine_dir(Direction.WEST, desired_dir)
	if Input.is_action_pressed("move_up_left"):
		desired_dir = Direction.combine_dir(Direction.NORTHWEST, desired_dir)
	if Input.is_action_pressed("move_up_right"):
		desired_dir = Direction.combine_dir(Direction.NORTHEAST, desired_dir)
	if Input.is_action_pressed("move_down_left"):
		desired_dir = Direction.combine_dir(Direction.SOUTHWEST, desired_dir)
	if Input.is_action_pressed("move_down_right"):
		desired_dir = Direction.combine_dir(Direction.SOUTHEAST, desired_dir)

	if not Input.is_action_pressed("stay"):
		_set_dir(desired_dir)
	$CharacterSprite.set_orient(desired_dir)

	if desired_dir != Direction.NONE:
		gameworld.send_event(events[EventDefs.P_INIT_MOV], MOVEMENT_MSG_TIME)


func _use_item() -> void:
	if held_item != null:
		if held_item is TargettedItem:
			var orient: int = $CharacterSprite.get_orient()
			held_item.set_targets($TargetTracker.get_targets(orient))
		held_item.use()
	else:
		$Reject.play()


func _process(_delta: float) -> void:
	if exists:
		if _future_dir != Direction.NONE and $MoveTimer.is_stopped():
			$MoveTimer.start()

		_handle_action()


func _ready() -> void:
	set_existence(false)
	var connect_status: int = connect("existence_changed", self, "_on_existence_changed")
	if connect_status != OK:
		printerr("Can not clean up Player when game ends.")


func _set_events():
	events.clear()
	events[EventDefs.P_INIT_MOV] = TileWorld.Event.new(MOVEMENT_MSG % $MoveTimer.wait_time, 1)
	events[EventDefs.P_INIT_PICK] = TileWorld.Event.new(ITEM_PICKUP_MSG, 1)


func spawn(spawned_into: TileWorld, pos: Vector2, orient: int = Direction.SOUTH) -> void:
	gameworld = spawned_into
	$CharacterSprite.set_orient(orient)
	position = pos

	_set_initial_lives()
	_set_events()
	set_existence(true)


func move_to(pos: Vector2) -> void:
	position = pos
	$WalkSFX.play()


func move_reject() -> void:
	$Reject.play()


func _on_MoveTimer_timeout() -> void:
	if _future_dir != Direction.NONE and exists:
		emit_signal("move_request", _future_dir)
		_future_dir = Direction.NONE


func _on_Player_area_entered(area: Area2D):
	if area is Item:
		if not held_item:
			held_item = area.acquire(self)
			gameworld.send_event(events[EventDefs.P_INIT_PICK], ITEM_PICKUP_MSG_TIME)

			var used_status: int = area.connect("used", self, "_on_item_used")
			if used_status != OK:
				printerr('Item "%s" cannot be used.' % area.type)

			var failed_status: int = area.connect("failed_use", self, "_on_item_failed_use")
			if failed_status != OK:
				printerr('Item "%s" cannot report failure.' % area.type)

			emit_signal("pick_up_item", held_item)
	elif area is Enemy:
		damage()
		area.damage()
		area.destroy()


func is_immortal() -> bool:
	return _immortal


func toggle_immortality() -> void:
	_immortal = not _immortal


func _on_item_used() -> void:
	if exists:
		emit_signal("used_item", held_item.type)
		held_item.queue_free()
		held_item = null


func _on_item_failed_use() -> void:
	$Reject.play()


func _on_existence_changed(value: bool) -> void:
	if not value:
		events.clear()
		gameworld = null
		held_item = null
		lives = 0

		_future_dir = Direction.NONE
		_immortal = false
