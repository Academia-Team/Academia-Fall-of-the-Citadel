tool
extends TargettedItem

const SWORD_SLASH: PackedScene = preload("res://scene/SwordAttack.tscn")

export var distance_between_slashes: float = 32
export var max_number_of_slashes: int = 2

var _slash_counter: int = 0
var _sword_slashed: bool = false
var _targets_to_destroy: Array = []


func _use() -> void:
	if not _sword_slashed:
		_slash_counter = _generate_slashes(max_number_of_slashes, distance_between_slashes)

		if _slash_counter > 0:
			for target in targets:
				if not target is Item:
					target.damage()
					_targets_to_destroy.append(target)
		else:
			emit_signal("failed_use")
	else:
		emit_signal("failed_use")


func _generate_slashes(num_slashes: int, dist_between: float) -> int:
	var num_pixels_away: float = dist_between
	var num_generated: int = 0
	var success: bool = true

	while success and num_generated < num_slashes:
		success = _generate_sword_slash(num_pixels_away)
		num_pixels_away += dist_between

		if success:
			num_generated += 1

	return num_generated


func _generate_sword_slash(num_pixels_away: float) -> bool:
	var slash_anim: CanvasItem = null
	var holder_orient: int = holder.get_orient()
	var target_pos: Vector2 = Direction.translate_pos(position, holder_orient, num_pixels_away)

	if gameworld.pos_in_world(target_pos):
		slash_anim = SWORD_SLASH.instance()
		slash_anim.position = target_pos

		var slash_status: int = slash_anim.connect(
			"animation_finished", self, "_slash_anim_finished"
		)
		if slash_status == OK:
			gameworld.add_child(slash_anim)
		else:
			printerr("Cannot generate sword slash.")
			slash_anim.free()
			slash_anim = null

	return slash_anim != null


func _slash_anim_finished() -> void:
	for target_to_destroy in _targets_to_destroy:
		if target_to_destroy != null:
			target_to_destroy.destroy()

	_targets_to_destroy.clear()

	_slash_counter -= 1
	if _slash_counter == 0:
		emit_signal("used")
