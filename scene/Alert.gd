extends AnimationPlayer


func _ready():
	$Bell.visible = false


func _on_Alert_animation_started(_anim_name):
	$SFX.play()
