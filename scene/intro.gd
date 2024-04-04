extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shouldFadeLabelOut
var fontRGBVal
var fontColor


# Called when the node enters the scene tree for the first time.
func _ready():
	shouldFadeLabelOut = false
	fontRGBVal = 0
	fontColor = Color8(fontRGBVal, fontRGBVal, fontRGBVal)
	$Label.add_color_override("font_color", getDesiredColor())

func getDesiredColor():
	return Color8(fontRGBVal, fontRGBVal, fontRGBVal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not shouldFadeLabelOut:
		fadeLabelIn()
	else:
		fadeLabelOut()

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
		call_deferred("free")
