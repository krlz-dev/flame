class_name AnimationStateComponent
extends Component

## Holds animation state data for state machine
## Supports 8-directional animations

enum State { IDLE, WALK }
enum Direction { SOUTH, SOUTH_WEST, WEST, NORTH_WEST, NORTH, NORTH_EAST, EAST, SOUTH_EAST }

# Map enum to animation name suffix (using hyphen format to match folder names)
const DIRECTION_NAMES = {
	Direction.SOUTH: "south",
	Direction.SOUTH_WEST: "south-west",
	Direction.WEST: "west",
	Direction.NORTH_WEST: "north-west",
	Direction.NORTH: "north",
	Direction.NORTH_EAST: "north-east",
	Direction.EAST: "east",
	Direction.SOUTH_EAST: "south-east"
}

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
	var dir_name = DIRECTION_NAMES[current_direction]
	match current_state:
		State.IDLE:
			return "idle_" + dir_name
		State.WALK:
			return "walk_" + dir_name
	return "idle_south"

static func direction_from_vector(vec: Vector2) -> Direction:
	if vec.length() < 0.1:
		return Direction.SOUTH

	# Calculate angle and map to 8 directions
	# Godot angles: 0 = right (east), PI/2 = down (south), PI = left (west), -PI/2 = up (north)
	var angle = vec.angle()

	# Normalize angle to 0-2PI range
	if angle < 0:
		angle += TAU

	# Each direction covers 45 degrees (PI/4), offset by 22.5 degrees (PI/8)
	# Direction order starting from East (angle 0) going clockwise:
	# East (0), South-East (PI/4), South (PI/2), South-West (3PI/4),
	# West (PI), North-West (5PI/4), North (3PI/2), North-East (7PI/4)
	var sector = int(round(angle / (PI / 4))) % 8

	match sector:
		0: return Direction.EAST
		1: return Direction.SOUTH_EAST
		2: return Direction.SOUTH
		3: return Direction.SOUTH_WEST
		4: return Direction.WEST
		5: return Direction.NORTH_WEST
		6: return Direction.NORTH
		7: return Direction.NORTH_EAST
		_: return Direction.SOUTH
