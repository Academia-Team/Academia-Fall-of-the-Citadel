extends ColorRect


func _ready() -> void:
	if get_tree().root.get_child(0) == self:
		($Book as Book).start()


func _on_Book_finished():
	($Book as Book).stop()
	if get_tree().root.get_child(0) == self:
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
