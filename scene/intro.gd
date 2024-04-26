extends ColorRect

const menu_scene = preload("res://scene/menu.tscn")

var shouldFadeLabelOut
var fontRGBVal
var fontColor

func _ready():
	shouldFadeLabelOut = false
	fontRGBVal = 0
	fontColor = Color8(fontRGBVal, fontRGBVal, fontRGBVal)
	$Label.add_color_override("font_color", getDesiredColor())
	
# Allow for skipping the animation.
func _unhandled_input(event):
	if event is InputEventKey or \
		event is InputEventGesture or \
		event is InputEventJoypadButton or \
		event is InputEventJoypadMotion or \
		event is InputEventMouseButton:
		$fadetimer.emit_signal("timeout")

func _process(_delta):
	if not shouldFadeLabelOut:
		fadeLabelIn()
	else:
		fadeLabelOut()

func getDesiredColor():
	return Color8(fontRGBVal, fontRGBVal, fontRGBVal)

func fadeLabelIn():
	if fontRGBVal <= 0xFF:
		fontRGBVal = fontRGBVal + 1
		$Label.add_color_override("font_color", getDesiredColor())
		
func fadeLabelOut():
	if fontRGBVal >= 0:
		fontRGBVal = fontRGBVal - 1
		$Label.add_color_override("font_color", getDesiredColor())

func _on_fadetimer_timeout():
	if not shouldFadeLabelOut:
		shouldFadeLabelOut = true
	else:
		get_tree().change_scene_to(menu_scene)
