class_name FocusedButton
extends Button

signal button_effects_finished
signal button_input(event)

export var select_sfx: AudioStream
export var activate_sfx: AudioStream

var select_audio_player: AudioStreamPlayer
var activate_audio_player: AudioStreamPlayer
var button_activated := false
var play_select_audio := true


func _ready() -> void:
	var m_entered_status: int = connect("mouse_entered", self, "_on_mouse_entered")
	var m_exited_status: int = connect("mouse_exited", self, "_on_mouse_exited")
	var f_exited_status: int = connect("focus_entered", self, "_on_focus_entered")
	var b_down_status: int = connect("button_down", self, "_on_button_down")
	var b_eff_status: int = connect("button_effects_finished", self, "_on_button_effects")
	var gui_input_status: int = connect("gui_input", self, "_on_gui_input")

	if not (
		m_entered_status == OK
		or m_exited_status == OK
		or f_exited_status == OK
		or b_down_status == OK
		or b_eff_status == OK
		or gui_input_status == OK
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


func grab_silent_focus() -> void:
	if get_focus_owner() != self:
		play_select_audio = false
		grab_focus()


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()


func _on_focus_entered() -> void:
	warp_mouse(Vector2.ZERO)

	if play_select_audio and not disabled:
		select_audio_player.stream = select_sfx
		select_audio_player.play()

	play_select_audio = true


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


func _on_button_effects() -> void:
	button_activated = false


func _on_gui_input(event: InputEvent) -> void:
	if not disabled:
		emit_signal("button_input", event)
