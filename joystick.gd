class_name Joystick
extends Control

## Virtual joystick for mobile input
## Emits direction vector for InputSystem to consume

signal input_changed(direction: Vector2)

var knob: ColorRect
var base: ColorRect
var is_pressed: bool = false
var max_distance: float = 50.0
var knob_size: Vector2 = Vector2(60, 60)

func _ready() -> void:
	# Create base circle
	base = ColorRect.new()
	base.color = Color(1, 1, 1, 0.3)
	base.size = size
	add_child(base)

	# Create knob
	knob = ColorRect.new()
	knob.color = Color(0.8, 0.8, 0.8, 0.7)
	knob.size = knob_size
	knob.position = size / 2.0 - knob_size / 2.0
	add_child(knob)

	max_distance = size.x / 3.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside(event.position):
				is_pressed = true
		else:
			is_pressed = false
			_reset_knob()

	elif event is InputEventScreenDrag:
		if is_pressed:
			_update_knob(event.position)

func _is_point_inside(point: Vector2) -> bool:
	var local_point = point - global_position
	return Rect2(Vector2.ZERO, size).has_point(local_point)

func _update_knob(touch_position: Vector2) -> void:
	var center = global_position + size / 2.0
	var direction = touch_position - center
	var distance = direction.length()

	if distance > max_distance:
		direction = direction.normalized() * max_distance

	knob.position = size / 2.0 - knob_size / 2.0 + direction

	var input_vector = direction / max_distance
	input_changed.emit(input_vector)

func _reset_knob() -> void:
	knob.position = size / 2.0 - knob_size / 2.0
	input_changed.emit(Vector2.ZERO)
