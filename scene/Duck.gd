tool
extends Item

var _duck_quacked: bool = false


func _use() -> void:
	if not _duck_quacked:
		$UseSFX.play()
		_duck_quacked = true
	else:
		emit_signal("failed_use")


func _on_UseSFX_finished() -> void:
	emit_signal("used")