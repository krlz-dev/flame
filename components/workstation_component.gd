class_name WorkstationComponent
extends Component

## Data for workstation/job location

@export var interaction_radius: float = 80.0
@export var interaction_offset: Vector2 = Vector2.ZERO  # Offset from entity center
@export var is_player_nearby: bool = false
