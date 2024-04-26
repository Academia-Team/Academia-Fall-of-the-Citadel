extends ColorRect

var orig_item_text = ""
var score

func _ready():
	score = 0

func _on_player_pick_up_item(item_name):
	orig_item_text = $item_info.text
	$item_info.text = item_name

func _on_player_used_item(_item_name):
	$item_info.text = orig_item_text

func _on_player_health_change(lives):
	$lives_counter.text = "Lives: %d" % lives

func _on_gamegrid_score_change(score_diff):
	score += score_diff
	$score_counter.text = "Score: %d" % score
