tool
class_name Item
extends InteractableObject

# warning-ignore:unused_signal
# The used signal is supposed to be used in all inheriting classes.
signal used
signal failed_use

const ITEM_DEFAULT_SCORE: int = 5

export var texture: Texture setget set_texture, get_texture
export var acquire_sfx: AudioStream setget set_acquire_sfx, get_acquire_sfx

var holder: Area2D = null
var gameworld: TileWorld = null

var _sprite: Sprite
var _acquire_sfx_player: AudioStreamPlayer


func _init() -> void:
	points = ITEM_DEFAULT_SCORE
	shovable = true

	var possible_sprite: Sprite = _get_sprite()
	if possible_sprite == null:
		_sprite = Sprite.new()
		add_child(_sprite, true)
		_sprite.set_owner(self)
	else:
		_sprite = possible_sprite
	_sprite.centered = false

	_acquire_sfx_player = AudioStreamPlayer.new()
	add_child(_acquire_sfx_player, true)


func _get_sprite() -> Sprite:
	for child in get_children():
		if child is Sprite:
			return child
	return null


func spawn(spawned_into: TileWorld, pos: Vector2) -> void:
	set_existence(true)
	gameworld = spawned_into
	position = pos


func use() -> void:
	if has_method("_use"):
		call("_use")
	else:
		printerr('Item "%s" has no _use() method.' % type)
		emit_signal("failed_use")


func set_acquire_sfx(value: AudioStream) -> void:
	acquire_sfx = value
	_acquire_sfx_player.stream = acquire_sfx


func get_acquire_sfx() -> AudioStream:
	return acquire_sfx


func acquire(acquiree: Area2D) -> Item:
	set_existence(false)
	holder = acquiree
	_acquire_sfx_player.play()

	return self


func destroy() -> void:
	queue_free()


func set_texture(value: Texture) -> void:
	texture = value
	_sprite.texture = value


func get_texture() -> Texture:
	return texture
