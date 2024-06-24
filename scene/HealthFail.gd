extends AnimationPlayer

var is_setup = false


func _ready():
	# Done so when play() is next called, it calls the desired animation.
	play("Flash")
	stop()

	is_setup = true
	$Health.visible = false


func _on_HealthFail_animation_started(_anim_name):
	if is_setup:
		$SFX.play()
