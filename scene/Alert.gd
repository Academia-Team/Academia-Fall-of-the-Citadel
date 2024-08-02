extends AnimationPlayer


func _ready() -> void:
	set_assigned_animation("Flash")
	($Bell as CanvasItem).hide()


func _on_Alert_animation_started(_anim_name: String) -> void:
	($SFX as AudioStreamPlayer).play()
