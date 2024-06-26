extends Line2D

signal animation_finished


func _init():
	yield(self, "ready")
	$AnimationPlayer.play("Slash")


func _on_AnimationPlayer_animation_finished(_anim_name):
	if not $SFX.is_playing():
		emit_signal("animation_finished")
		queue_free()


func _on_SFX_finished():
	if not $AnimationPlayer.is_playing():
		emit_signal("animation_finished")
		queue_free()
