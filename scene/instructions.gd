extends ColorRect

const NUM_PAGES = 3
var curr_page = null
var page_counter = 0

signal finished()
signal switched_to_page(page_num)

func _ready():
	hide_all_pages()
	handle_page_request()

func _process(_delta):
	if Input.is_action_just_pressed("ui_advance"):
		handle_page_request()

func get_next_page():
	var next_page = null
	page_counter += 1
	
	if page_counter <= NUM_PAGES:
		var page_node_name = "Pg%d" % page_counter
		next_page = get_node(page_node_name)
	
	return next_page

func handle_page_request():
	var next_page = get_next_page()
	
	if next_page != null:
		if curr_page != null:
			curr_page.hide()
		
		next_page.show()
		curr_page = next_page
		
		emit_signal("switched_to_page", page_counter)
	else:
		emit_signal("finished")
		SceneSwitcher.change_scene_tree_to(get_tree(), SceneSwitcher.MENU)

func hide_all_pages():
	var children = get_children()
	
	for child in children:
		if child.name.begins_with("Pg"):
			child.hide()

func reset():
	curr_page = null
	page_counter = 0
