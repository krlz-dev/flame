class_name InputSystem
extends System

## Receives input from joystick and updates entities with InputComponent
## Supports 8-directional movement

var target_entity: Node = null

func get_required_components() -> Array[String]:
	return ["input"]

func set_target(entity: Node) -> void:
	target_entity = entity

func receive_input(direction: Vector2) -> void:
	if target_entity and target_entity.has_meta("input"):
		var input_comp: InputComponent = target_entity.get_meta("input")
		# Allow 8-directional movement with snapping to 45-degree angles
		input_comp.direction = _snap_to_8_directions(direction)

func _snap_to_8_directions(dir: Vector2) -> Vector2:
	if dir.length() < 0.1:
		return Vector2.ZERO

	# Calculate angle and snap to nearest 45-degree direction
	var angle = dir.angle()
	# Snap to 8 directions (every 45 degrees = PI/4)
	var snap_angle = round(angle / (PI / 4)) * (PI / 4)
	return Vector2.from_angle(snap_angle)
