tool
class_name Item
extends InteractableObject

export var type: String
export var texture: Texture setget set_texture, get_texture
export var acquire_sfx: AudioStream


func _ready() -> void:
	shovable = true
	($AcquireSFX as AudioStreamPlayer).stream = acquire_sfx


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
