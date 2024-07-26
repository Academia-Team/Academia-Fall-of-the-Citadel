class_name Item
extends Area2D

export var shovable: bool = true
export var type: String
export var sprite: Texture
export var acquire_sfx: AudioStream
export var shove_sfx: AudioStream


func _ready() -> void:
	($Sprite as Sprite).texture = sprite
	($AcquireSFX as AudioStreamPlayer).stream = acquire_sfx
	($ShoveSFX as AudioStreamPlayer).stream = shove_sfx


func get_class() -> String:
	return "Item"


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
		$ShoveSFX.play()
	else:
		print("Attempted to shove unshovable object.")


func is_shovable() -> bool:
	return shovable


func destroy() -> void:
	queue_free()
