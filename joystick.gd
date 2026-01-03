class_name Joystick
extends Control

## Touch anywhere to move - invisible joystick
## Drag from touch point to determine direction

signal input_changed(direction: Vector2)

var is_pressed: bool = false
var touch_start: Vector2 = Vector2.ZERO
var touch_index: int = -1

func _ready() -> void:
	# Make control cover the full screen for touch anywhere
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_index == -1:
				touch_index = event.index
				touch_start = event.position
				is_pressed = true
		else:
			if event.index == touch_index:
				touch_index = -1
				is_pressed = false
				input_changed.emit(Vector2.ZERO)

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			var direction = event.position - touch_start
			var input_vector = direction.normalized() if direction.length() > 10.0 else Vector2.ZERO
			input_changed.emit(input_vector)
