tool
extends "res://addons/OrientedSprite/type.gd"

signal effect_changed

const MAX_EFFECTS := 3

export var death_texture: Texture setget set_death_texture

export var heal_color := Color.pink
export var hurt_color := Color.tomato
export var heal_length := 1.0
export var hurt_length := 0.3

var _tint_stack := Stack.new()


func _init() -> void:
	_tint_stack.set_size(MAX_EFFECTS)

	var tint_connect: int = _tint_stack.connect("contents_changed", self, "_on_tint_changed")
	if tint_connect == OK:
		var push_success: bool = _tint_stack.push(self_modulate)
		if not push_success:
			printerr("Failed to push initial effect data.")
	else:
		printerr("Unable to keep track of creature effects.")


func set_death_texture(new_texture: Texture) -> void:
	death_texture = new_texture


func show_heal(length: float = heal_length) -> void:
	_show_effect(length, heal_color)


func show_hurt(length: float = hurt_length) -> void:
	_show_effect(length, hurt_color)


func show_death() -> void:
	texture = death_texture


func _show_effect(length: float, color: Color) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(length)
	var tint := Expirable.new(color, timer)
	_tint_stack.push(tint)


func _on_tint_changed() -> void:
	var tint = _tint_stack.peek()
	var color: Color

	if tint is Color:
		color = tint

	if tint is Expirable:
		color = tint.get_item()

	self_modulate = color
	emit_signal("effect_changed")
