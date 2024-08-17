tool
extends "res://addons/OrientedSprite/type.gd"

signal effect_show
signal effect_finish

export var death_texture: Texture setget set_death_texture

export var heal_color: Color = Color.pink
export var hurt_color: Color = Color.tomato
export var heal_length: float = 1.0
export var hurt_length: float = 0.3

var effect_timer: Timer
var initial_texture: Texture
onready var orig_self_modulate: Color = self_modulate


func _ready() -> void:
	effect_timer = Timer.new()
	effect_timer.one_shot = true
	var connect_status: int = effect_timer.connect("timeout", self, "_on_effect_timeout")

	if connect_status != OK:
		printerr("Timer connect failure: Status effects will be displayed indefinitely.")

	add_child(effect_timer)


func set_death_texture(new_texture: Texture) -> void:
	death_texture = new_texture


func show_heal(length: float = heal_length) -> void:
	_show_effect(length, heal_color)


func show_hurt(length: float = hurt_length) -> void:
	_show_effect(length, hurt_color)


func show_death() -> void:
	texture = death_texture


func _show_effect(length: float, color: Color) -> void:
	if not effect_timer.is_stopped():
		effect_timer.stop()
		effect_timer.emit_signal("timeout")
		yield(effect_timer, "timeout")

	effect_timer.wait_time = length

	orig_self_modulate = self_modulate
	self_modulate = color

	effect_timer.start()
	emit_signal("effect_show")


func _on_effect_timeout() -> void:
	self_modulate = orig_self_modulate
	emit_signal("effect_finish")
