class_name FocusedButton
extends Button

signal button_effects_finished

export var select_sfx: AudioStream
export var activate_sfx: AudioStream

var select_audio_player: AudioStreamPlayer
var activate_audio_player: AudioStreamPlayer
var button_activated: bool = false


func _ready() -> void:
	var m_entered_status: int = connect("mouse_entered", self, "_on_mouse_entered")
	var m_exited_status: int = connect("mouse_exited", self, "_on_mouse_exited")
	var f_exited_status: int = connect("focus_entered", self, "_on_focus_entered")
	var b_down_status: int = connect("button_down", self, "_on_button_down")

	if not (
		m_entered_status == OK
		or m_exited_status == OK
		or f_exited_status == OK
		or b_down_status == OK
	):
		printerr("Internal FocusedButton Failure.")

	select_audio_player = AudioStreamPlayer.new()
	activate_audio_player = AudioStreamPlayer.new()

	add_child(select_audio_player)
	add_child(activate_audio_player)

	var audio_player_status: int = activate_audio_player.connect(
		"finished", self, "_on_audio_finished"
	)

	if audio_player_status != OK:
		printerr("FocusedButton: Cannot connect to AudioStreamPlayer.")


func _on_mouse_entered() -> void:
	grab_focus()
	select_audio_player.stream = select_sfx
	select_audio_player.play()


func _on_mouse_exited() -> void:
	release_focus()


func _on_focus_entered() -> void:
	warp_mouse(Vector2.ZERO)
	select_audio_player.stream = select_sfx
	select_audio_player.play()


func _on_button_down() -> void:
	if not button_activated:
		activate_audio_player.stream = activate_sfx
		button_activated = true

		if activate_audio_player.stream != null:
			activate_audio_player.play()
		else:
			emit_signal("button_effects_finished")


func _on_audio_finished() -> void:
	emit_signal("button_effects_finished")
	button_activated = false
