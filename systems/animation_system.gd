class_name AnimationSystem
extends System

## State machine for character animations
## Processes entities with AnimationStateComponent and updates their AnimatedSprite2D

func get_required_components() -> Array[String]:
	return ["animation_state", "input"]

func process_system(_delta: float) -> void:
	for entity in get_entities():
		var anim_state: AnimationStateComponent = entity.get_meta("animation_state")
		var input_comp: InputComponent = entity.get_meta("input")

		# Update direction based on input
		if input_comp.direction.length() > 0.1:
			var new_dir = AnimationStateComponent.direction_from_vector(input_comp.direction)
			anim_state.set_direction(new_dir)
			anim_state.set_state(AnimationStateComponent.State.WALK)
		else:
			anim_state.set_state(AnimationStateComponent.State.IDLE)

		# Update animation if state changed
		if anim_state.state_changed():
			_update_animation(entity, anim_state)

		# Reset change tracking
		anim_state.previous_state = anim_state.current_state
		anim_state.previous_direction = anim_state.current_direction

func _update_animation(entity: Node, anim_state: AnimationStateComponent) -> void:
	var animated_sprite = entity.get_node_or_null("AnimatedSprite2D")
	if animated_sprite and animated_sprite is AnimatedSprite2D:
		var anim_name = anim_state.get_animation_name()
		if animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
