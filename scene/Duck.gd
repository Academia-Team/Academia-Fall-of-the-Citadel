tool
extends Item

var _duck_quacked: bool = false


func ready() -> void:
	var use_connect: int = $UseSFX.connect("finished", self, "_on_UseSFX_finished")
	if use_connect != OK:
		printerr("%s will never report a successful use." % type)


func _use() -> void:
	if not _duck_quacked:
		$UseSFX.play()
		_duck_quacked = true
	else:
		emit_signal("failed_use")


func _on_UseSFX_finished() -> void:
	emit_signal("used")
