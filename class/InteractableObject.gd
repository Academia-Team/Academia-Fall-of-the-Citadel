class_name InteractableObject
extends Area2D

signal existence_changed(value)

export var points: int = 0 setget set_points, get_points
export var shovable: bool = false setget set_shovable, is_shovable
export var shovable_sfx: AudioStream = null setget set_shovable_sfx, get_shovable_sfx

const GROUP: String = "interactable"

var exists: bool = true setget set_existence, get_existence

var _shovable_sfx_player: AudioStreamPlayer = null


func _init() -> void:
	_shovable_sfx_player = AudioStreamPlayer.new()
	add_to_group(GROUP, true)


func set_shovable(value: bool) -> void:
	shovable = value


func is_shovable() -> bool:
	return shovable


func set_shovable_sfx(value: AudioStream) -> void:
	shovable_sfx = value
	_shovable_sfx_player.stream = shovable_sfx


func get_shovable_sfx() -> AudioStream:
	return shovable_sfx


func shove_to(pos: Vector2) -> bool:
	if shovable:
		position = pos
		($ShoveSFX as AudioStreamPlayer).play()
	return shovable


func set_points(value: int):
	points = value


func get_points() -> int:
	return points


func set_existence(value: bool) -> void:
	exists = value
	set_visible(exists)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not exists)
		elif child is TargetTracker:
			if exists:
				child.enable()
			else:
				child.disable()
	emit_signal("existence_changed", value)


func get_existence() -> bool:
	return exists
