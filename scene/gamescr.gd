extends Control

const game_over_scene = preload("res://scene/gameover.tscn")
var menu_scene = load("res://scene/menu.tscn")

var seed_val = null

func _ready():
	if seed_val == null:
		seed_val = gen_seed()
	
		if OS.is_debug_build():
			print("Seed: %d" % seed_val)

	$gamegrid.start($infobar, seed_val)

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		var status = get_tree().change_scene_to(menu_scene)
		
		if status != OK:
			printerr("Failed to switch to menu.")

func gen_seed():
	var gen_seed_val = hash(Time.get_datetime_dict_from_system())
	
	return gen_seed_val


func _on_gamegrid_tree_exited():
	var gameover = game_over_scene.instance()
	gameover.connect("retry", self, "_on_gameover_retry")
	gameover.connect("leave", self, "_on_gameover_leave")
	add_child(gameover)
	gameover.start($infobar, seed_val)

func _on_gameover_retry():
	var status = get_tree().reload_current_scene()
	
	if status != OK:
		printerr("Failed to reload game.")

func _on_gameover_leave():
	var status = get_tree().change_scene_to(menu_scene)
	
	if status != OK:
			printerr("Failed to switch to menu.")
