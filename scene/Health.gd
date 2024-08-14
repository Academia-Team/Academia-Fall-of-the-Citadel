tool
extends Item

var _health_used: bool = false


func _use() -> void:
	if not _health_used:
		if holder.lives_lost() > 0:
			holder.heal()
			$UseSFX.play()
		else:
			$Fail.play()


func _on_UseSFX_finished() -> void:
	emit_signal("used")


func _on_Fail_animation_finished(_anim_name: String) -> void:
	emit_signal("used")
