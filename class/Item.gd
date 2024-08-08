tool
class_name Item
extends Area2D

export var shovable: bool = true
export var type: String
export var texture: Texture setget set_texture, get_texture
export var acquire_sfx: AudioStream
export var shove_sfx: AudioStream


func _ready() -> void:
	($AcquireSFX as AudioStreamPlayer).stream = acquire_sfx
	($ShoveSFX as AudioStreamPlayer).stream = shove_sfx


func acquire() -> Item:
	.hide()
	($Collisionbox as CollisionShape2D).set_deferred("disabled", true)
	($AcquireSFX as AudioStreamPlayer).play()
	return self


func exists() -> bool:
	return visible


func shove_to(pos: Vector2) -> void:
	if shovable:
		position = pos
		($ShoveSFX as AudioStreamPlayer).play()
	else:
		print("Attempted to shove unshovable object.")


func is_shovable() -> bool:
	return shovable


func destroy() -> void:
	queue_free()


func set_texture(value: Texture) -> void:
	texture = value
	($Sprite as Sprite).set_texture(value)


func get_texture() -> Texture:
	return texture
