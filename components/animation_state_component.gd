class_name AnimationStateComponent
extends Component

## Holds animation state data for state machine

enum State { IDLE, WALK }
enum Direction { SOUTH, WEST, EAST, NORTH }

@export var current_state: State = State.IDLE
@export var current_direction: Direction = Direction.SOUTH
@export var previous_state: State = State.IDLE
@export var previous_direction: Direction = Direction.SOUTH

func set_state(new_state: State) -> void:
	previous_state = current_state
	current_state = new_state

func set_direction(new_direction: Direction) -> void:
	previous_direction = current_direction
	current_direction = new_direction

func state_changed() -> bool:
	return current_state != previous_state or current_direction != previous_direction

func get_animation_name() -> String:
	var dir_name = Direction.keys()[current_direction].to_lower()
	match current_state:
		State.IDLE:
			return "idle_" + dir_name
		State.WALK:
			return "walk_" + dir_name
	return "idle_south"

static func direction_from_vector(vec: Vector2) -> Direction:
	if vec.length() < 0.1:
		return Direction.SOUTH

	# Determine primary direction based on vector
	if abs(vec.x) > abs(vec.y):
		return Direction.EAST if vec.x > 0 else Direction.WEST
	else:
		return Direction.SOUTH if vec.y > 0 else Direction.NORTH
