class_name Credits
extends ColorRect

signal done


func _ready() -> void:
	stop()


func start() -> void:
	($ScrollContainer as Control).grab_focus()
	($ScrollContainer as AutomatedScrollContainer).play()
	($TitleAnimation/Label as CanvasItem).visible = true
	($TitleAnimation as AnimationPlayer).play("Fade Out")
	($Music as Jukebox).start()


func stop() -> void:
	($TitleAnimation as AnimationPlayer).play("RESET")
	($TitleAnimation/Label as CanvasItem).visible = false
	($ScrollContainer as AutomatedScrollContainer).stop()
	($ScrollContainer as ScrollContainer).set_deferred("scroll_vertical", 0)
	($Music as Jukebox).end()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_ScrollContainer_gui_input(event: InputEvent) -> void:
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
