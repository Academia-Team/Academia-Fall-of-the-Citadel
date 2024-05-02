extends ColorRect

const SCROLL_SPEED = 16

func _ready():
	$ScrollContainer.grab_focus()


func _on_ScrollContainer_gui_input(event):
	var curr_vscroll_val = $ScrollContainer.get_v_scroll()
	if event.is_action("ui_scroll_down", true):
		$ScrollContainer.set_v_scroll(curr_vscroll_val + SCROLL_SPEED)
	if event.is_action("ui_scroll_up", true):
		$ScrollContainer.set_v_scroll(curr_vscroll_val - SCROLL_SPEED)
