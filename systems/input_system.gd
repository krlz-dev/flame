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
		input_comp.direction = direction
