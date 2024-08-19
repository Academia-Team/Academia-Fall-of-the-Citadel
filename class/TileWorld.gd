# Adds helper methods to a TileMap to make it easier to create a game world.

class_name TileWorld
extends TileMap

signal message_change_request(text, duration)
signal music_change_request(stream, duration)

const EVENT_NO_LIMIT := -1


class Event:
	extends Reference

	var num_times: int
	var max_times: int

	var message: String
	var music: AudioStream

	func _init(text: String, max_occurences: int = EVENT_NO_LIMIT, song: AudioStream = null):
		num_times = 0
		max_times = max_occurences

		message = text
		music = song


func send_event(event: Event, duration: float = EVENT_NO_LIMIT) -> void:
	if event.max_times == EVENT_NO_LIMIT or event.num_times < event.max_times:
		event.num_times += 1
		emit_signal("message_change_request", event.message, duration)
		if event.music != null:
			emit_signal("music_change_request", event.music, duration)


func pos_in_world(pos: Vector2) -> bool:
	return get_cellv(world_to_map(pos)) != INVALID_CELL
