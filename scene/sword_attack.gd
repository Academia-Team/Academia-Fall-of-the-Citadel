extends Line2D

signal animation_finished

func _init():
	yield(self, "ready")
	$AnimationPlayer.play("Slash")


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("animation_finished")
	call_deferred("free")
