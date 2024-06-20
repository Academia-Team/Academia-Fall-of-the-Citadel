extends Area2D
class_name Item

export(bool) var shovable = true
export(String) var type
export(Texture) var sprite
export(AudioStream) var acquire_sfx
export(AudioStream) var shove_sfx


func _ready():
	$Sprite.texture = sprite
	$AcquireSFX.stream = acquire_sfx
	$ShoveSFX.stream = shove_sfx


func get_class():
	return "Item"


func acquire():
	.hide()
	$Collisionbox.set_deferred("disabled", true)
	$AcquireSFX.play()
	return self


func exists():
	return visible


func shove_to(pos):
	if shovable:
		position = pos
		$ShoveSFX.play()
	else:
		print("Attempted to shove unshovable object.")


func is_shovable():
	return shovable


func destroy():
	queue_free()
