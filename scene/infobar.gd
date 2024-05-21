extends ColorRect

var _cur_status_text = ""
var _lives = 0
var _mode = null
var _orig_status_text = ""
var _score = 0
var _seed = null

var _cheat_enabled = false
var _tainted = false

func _ready():
	_cur_status_text = $status.text
	_orig_status_text = $status.text

func reset():
	$StatusTimer.stop()
	_lives = 0
	_score = 0
	_seed = null
	
	_write_score_text()
	_write_lives_text()
	reset_status()

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

func set_mode(mode):
	_mode = mode

func get_mode():
	return _mode

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

func set_timed_status(status_str, sec = 3):
	$status.text = status_str
	
	# Ensure all other timed status messages are replaced.
	if not $StatusTimer.is_stopped():
		$StatusTimer.stop()
	
	$StatusTimer.start(sec)

# All timed status messages have priority above non-timed status messages.
func set_status(status_str):
	if $StatusTimer.is_stopped():
		_orig_status_text = $status.text
		$status.text = status_str
		
	_cur_status_text = status_str

func get_status():
	return $status.text

# Has no effect on temporary (timed) status messages.
# Those will be reset when the timer times out.
func reset_status():
	if $StatusTimer.is_stopped():
		$status.text = _orig_status_text

	_cur_status_text = _orig_status_text

func toggle_cheats():
	_cheat_enabled = not _cheat_enabled
	_tainted = true

func is_cheat_enabled():
	return _cheat_enabled


func _on_StatusTimer_timeout():
	$status.text = _cur_status_text
