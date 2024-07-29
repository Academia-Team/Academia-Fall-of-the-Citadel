class_name AutomatedScrollContainer
extends ScrollContainer

enum ScrollType {SCROLL_UP, SCROLL_DOWN}

export var vert_scroll_amount: int = 16
export var autostart: bool = false
export(ScrollType) var scroll_direction: int = ScrollType.SCROLL_DOWN
export var time_between_scrolls: float = 0.1

var curr_scroll_dir: int
var is_automated: bool
var scroll_fail: bool = false

var scrollTimer: Timer

signal begin_reached(automated)
signal end_reached(automated)


func _ready() -> void:
	scrollTimer = Timer.new()
	add_child(scrollTimer)
	var connect_status: int = scrollTimer.connect("timeout", self, "_on_ScrollTimer_timeout")

	if connect_status != OK:
		printerr("Timer connect failure: Automated scrolling will be disabled.")
		scroll_fail = true

	if autostart:
		play()


func play(scrollType: int = scroll_direction, scrollTime: float = time_between_scrolls) -> void:
	if not scroll_fail:
		is_automated = true
		curr_scroll_dir = scrollType

		scrollTimer.stop()
		scrollTimer.wait_time = scrollTime
		scrollTimer.start()


func stop() -> void:
	is_automated = false
	scrollTimer.stop()


func _on_ScrollTimer_timeout():
	match curr_scroll_dir:
		ScrollType.SCROLL_UP:
			scroll_up()
		ScrollType.SCROLL_DOWN:
			scroll_down()
		_:
			printerr("Attempt to scroll in invalid direction %d." % curr_scroll_dir)


func scroll_down(scroll_val: int = vert_scroll_amount) -> void:
	var curr_vscroll_val: int = get_v_scroll()
	set_v_scroll(curr_vscroll_val + scroll_val)

	if curr_vscroll_val == get_v_scroll():
		emit_signal("end_reached", is_automated)


func scroll_up(scroll_val: int = vert_scroll_amount) -> void:
	var curr_vscroll_val: int = get_v_scroll()
	set_v_scroll(curr_vscroll_val - scroll_val)

	if curr_vscroll_val == get_v_scroll():
		emit_signal("begin_reached", is_automated)