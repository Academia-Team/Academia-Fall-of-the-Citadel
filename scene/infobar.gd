extends ColorRect

var score

func _ready():
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_player_pick_up_item(item_name):
	$item_info.text = item_name


func _on_player_used_item(_item_name):
	$item_info.text = ""

func _on_player_health_change(lives):
	$lives_counter.text = "Lives: %d" % lives

func _on_gamegrid_score_change(score_diff):
	score += score_diff
	$score_counter.text = "Score: %d" % score
