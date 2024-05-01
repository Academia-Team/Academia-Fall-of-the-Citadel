extends ColorRect

var _lives = 0
var _orig_item_text = ""
var _score = 0
var _seed = null

func incr_score(score_delta):
	_score += score_delta
	_write_score_text()

func decr_score(score_delta):
	if score_delta > _score:
		_score = 0
	else:
		_score -= score_delta
	
	_write_score_text()

func _write_score_text():
	$score_counter.text = "Score: %d" % _score

func get_score():
	return _score

func get_score_text():
	return $score_counter.text

func set_lives(life_count):
	if life_count >= 0:
		_lives = life_count
		_write_lives_text()

func decr_lives():
	if _lives > 0:
		_lives -= 1
		_write_lives_text()

func incr_lives():
	_lives += 1
	_write_lives_text()

func get_lives():
	return _lives

func _write_lives_text():
	$lives_counter.text = "Lives: %d" % _lives

func get_lives_text():
	return $lives_counter

func set_seed(seed_val):
	_seed = seed_val

func get_seed():
	return _seed

func set_status(status_str):
	_orig_item_text = $status.text
	$status.text = status_str

func get_status():
	return $status.text

func reset_status():
	$status.text = _orig_item_text
