tool
extends Item

const DUCK_HOLDER_META := "duck_count"

const MEGA_DUCK_READY := "Mega Duck Primed..."
const MEGA_DUCK_READY_TIME := 3.0

const MEGA_DUCK_ACTIVE := "Duck Power!"

export var mega_duck_color := Color.gold setget set_mega_duck_color, get_mega_duck_color
export var mega_duck_music: AudioStream setget set_mega_duck_music, get_mega_duck_music
export var mega_duck_time := 3.492 setget set_mega_duck_time, get_mega_duck_time
export var mega_duck_uses := 20 setget set_mega_duck_uses, get_mega_duck_uses

var _duck_quacked := false


func set_mega_duck_color(value: Color) -> void:
	mega_duck_color = value


func get_mega_duck_color() -> Color:
	return mega_duck_color


func set_mega_duck_music(value: AudioStream) -> void:
	mega_duck_music = value


func get_mega_duck_music() -> AudioStream:
	return mega_duck_music


func set_mega_duck_time(value: float) -> void:
	if value > 0:
		mega_duck_time = value


func get_mega_duck_time() -> float:
	return mega_duck_time


func set_mega_duck_uses(value: int) -> void:
	if value > 0:
		mega_duck_uses = value


func get_mega_duck_uses() -> int:
	return mega_duck_uses


func _acquire() -> void:
	if not holder.has_meta(DUCK_HOLDER_META) or holder.get_meta(DUCK_HOLDER_META) >= mega_duck_uses:
		holder.set_meta(DUCK_HOLDER_META, 0)

	if holder.get_meta(DUCK_HOLDER_META) == (mega_duck_uses - 1):
		var ready_event := TileWorld.Event.new(EventDefs.D_READY, MEGA_DUCK_READY)
		gameworld.send_event(ready_event, MEGA_DUCK_READY_TIME)


func _use() -> void:
	if not _duck_quacked:
		holder.set_meta(DUCK_HOLDER_META, holder.get_meta(DUCK_HOLDER_META) + 1)

		if holder.get_meta(DUCK_HOLDER_META) == mega_duck_uses:
			var active_event := TileWorld.Event.new(
				EventDefs.D_MEGA, MEGA_DUCK_ACTIVE, 1, mega_duck_music, mega_duck_color
			)
			gameworld.send_event(active_event, mega_duck_time)
			emit_signal("used")
		else:
			$UseSFX.play()
			_duck_quacked = true
	else:
		emit_signal("failed_use")


func _on_UseSFX_finished() -> void:
	emit_signal("used")


func _on_holder_existence_changed(value: bool) -> void:
	if not value and holder.has_meta(DUCK_HOLDER_META):
		holder.remove_meta(DUCK_HOLDER_META)
