class_name InputSystem
extends System

## Receives input from joystick and updates entities with InputComponent

var target_entity: Node = null

func get_required_components() -> Array[String]:
	return ["input"]

func set_target(entity: Node) -> void:
	target_entity = entity

func receive_input(direction: Vector2) -> void:
	if target_entity and target_entity.has_meta("input"):
		var input_comp: InputComponent = target_entity.get_meta("input")
		# Restrict to 4 directions (no diagonal)
		input_comp.direction = _snap_to_cardinal(direction)

func _snap_to_cardinal(dir: Vector2) -> Vector2:
	if dir.length() < 0.1:
		return Vector2.ZERO
	# Use the axis with larger magnitude
	if abs(dir.x) > abs(dir.y):
		return Vector2(sign(dir.x), 0)
	else:
		return Vector2(0, sign(dir.y))
