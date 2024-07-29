extends ColorRect


func _ready() -> void:
	$ScrollContainer.grab_focus()
	$TitleAnimation.play("Fade Out")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)


func _on_ScrollContainer_gui_input(event: InputEvent):
	var scroll_container = $ScrollContainer as AutomatedScrollContainer

	if event.is_action("ui_scroll_down", true):
		scroll_container.stop()
		scroll_container.scroll_down()
	if event.is_action("ui_scroll_up", true):
		scroll_container.stop()
		scroll_container.scroll_up()

func _on_ScrollContainer_begin_reached(automated: bool):
	if automated:
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
	else:
		($Alert as AnimationPlayer).play()


func _on_ScrollContainer_end_reached(automated: bool):
	if automated:
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
	else:
		($Alert as AnimationPlayer).play()
