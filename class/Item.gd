tool
class_name Item
extends InteractableObject

signal used
signal failed_use

const ITEM_DEFAULT_SCORE: int = 5

export var texture: Texture setget set_texture, get_texture
export var acquire_sfx: AudioStream setget set_acquire_sfx, get_acquire_sfx

var _gamegrid: GameGrid = null
var _owner: Area2D = null


func _init() -> void:
	points = ITEM_DEFAULT_SCORE
	shovable = true


func spawn(spawned_into: GameGrid, pos: Vector2) -> void:
	set_existence(true)
	_gamegrid = spawned_into
	position = pos


func use() -> void:
	if has_method("_use"):
		call("_use")
	else:
		printerr('Item "%s" has no _use() method.' % type)
		emit_signal("failed_use")


func set_acquire_sfx(value: AudioStream) -> void:
	acquire_sfx = value
	($AcquireSFX as AudioStreamPlayer).stream = acquire_sfx


func get_acquire_sfx() -> AudioStream:
	return acquire_sfx


func acquire(acquiree: Area2D) -> Item:
	set_existence(false)
	_owner = acquiree
	($AcquireSFX as AudioStreamPlayer).play()

	return self


func destroy() -> void:
	queue_free()


func set_texture(value: Texture) -> void:
	texture = value
	($Sprite as Sprite).set_texture(value)


func get_texture() -> Texture:
	return texture
