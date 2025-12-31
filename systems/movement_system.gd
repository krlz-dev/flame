class_name MovementSystem
extends System

## Processes entities with VelocityComponent and InputComponent
## Moves CharacterBody2D entities based on input

func get_required_components() -> Array[String]:
	return ["velocity", "input"]

func process_system(_delta: float) -> void:
	for entity in get_entities():
		var velocity_comp: VelocityComponent = entity.get_meta("velocity")
		var input_comp: InputComponent = entity.get_meta("input")

		if entity is CharacterBody2D and input_comp.is_active:
			velocity_comp.velocity = input_comp.direction * velocity_comp.max_speed
			entity.velocity = velocity_comp.velocity
			entity.move_and_slide()
