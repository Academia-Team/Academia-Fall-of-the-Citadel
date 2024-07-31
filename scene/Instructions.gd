extends ColorRect

signal finished
signal switched_to_page(page_num)

var _curr_page: CanvasItem
var _page_counter: int


func _ready() -> void:
	start()


func start() -> void:
	stop()
	_handle_page_request()


func stop() -> void:
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Page", "hide")
	_curr_page = null
	_page_counter = -1


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_advance") and _curr_page != null:
		_handle_page_request()


func get_next_page() -> CanvasItem:
	var page: CanvasItem = null
	var pages: Array = get_tree().get_nodes_in_group("Page")
	var next_page_count: int = _page_counter + 1

	if next_page_count < pages.size():
		page = pages[next_page_count]

	return page


func _handle_page_request() -> void:
	var next_page: CanvasItem = get_next_page()

	if next_page != null:
		if _curr_page != null:
			_curr_page.hide()

		next_page.show()
		_curr_page = next_page
		_page_counter += 1

		emit_signal("switched_to_page", _page_counter)
	else:
		emit_signal("finished")
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)
