tool
class_name Item
extends InteractableObject

const ITEM_DEFAULT_SCORE: int = 5

export var type: String
export var texture: Texture setget set_texture, get_texture
export var acquire_sfx: AudioStream setget set_acquire_sfx, get_acquire_sfx


func _init() -> void:
	points = ITEM_DEFAULT_SCORE
	shovable = true


func set_acquire_sfx(value: AudioStream) -> void:
	acquire_sfx = value
	($AcquireSFX as AudioStreamPlayer).stream = acquire_sfx


func get_acquire_sfx() -> AudioStream:
	return acquire_sfx


func acquire() -> Item:
	.hide()
	($Collisionbox as CollisionShape2D).set_deferred("disabled", true)
	($AcquireSFX as AudioStreamPlayer).play()
	return self


func destroy() -> void:
	queue_free()


func set_texture(value: Texture) -> void:
	texture = value
	($Sprite as Sprite).set_texture(value)


func get_texture() -> Texture:
	return texture
