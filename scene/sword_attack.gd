extends Line2D

func _init():
	yield(self, "ready")
	$AnimationPlayer.play("Slash")


func _on_AnimationPlayer_animation_finished(_anim_name):
	call_deferred("free")
