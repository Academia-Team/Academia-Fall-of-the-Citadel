class_name Credits
extends ColorRect

signal done

var _credits_active: bool = false


func _ready() -> void:
	stop()
	#$ScrollContainer/VBoxContainer/Body.text_file = preload("res://LICENSE.txt")


func start() -> void:
	($ScrollContainer as Control).grab_focus()
	($ScrollContainer as AutomatedScrollContainer).play()
	($TitleAnimation/Label as CanvasItem).visible = true
	($TitleAnimation as AnimationPlayer).play("Fade Out")
	($Music as Jukebox).start()
	show()
	_credits_active = true


func stop() -> void:
	($TitleAnimation as AnimationPlayer).play("RESET")
	($TitleAnimation/Label as CanvasItem).visible = false
	($ScrollContainer as AutomatedScrollContainer).stop()
	($ScrollContainer as ScrollContainer).set_deferred("scroll_vertical", 0)
	($Music as Jukebox).end()
	hide()
	_credits_active = false


func _process(_delta: float) -> void:
	if _credits_active and Input.is_action_just_pressed("quit"):
		emit_signal("done")


func _on_ScrollContainer_gui_input(event: InputEvent) -> void:
	if _credits_active:
		var scroll_container = $ScrollContainer as AutomatedScrollContainer

		if event.is_action("ui_scroll_down", true):
			scroll_container.stop()
			scroll_container.scroll_down()
		if event.is_action("ui_scroll_up", true):
			scroll_container.stop()
			scroll_container.scroll_up()


func _on_ScrollContainer_begin_reached(automated: bool) -> void:
	if automated:
		emit_signal("done")
	else:
		($Alert as AnimationPlayer).play()


func _on_ScrollContainer_end_reached(automated: bool) -> void:
	if automated:
		emit_signal("done")
	else:
		($Alert as AnimationPlayer).play()
