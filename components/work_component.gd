class_name WorkComponent
extends Component

## Tracks current work/job in progress

@export var is_working: bool = false
@export var current_job_id: int = -1
@export var work_time: float = 0.0
@export var work_duration: float = 0.0
@export var reward: int = 0

func start_job(job_id: int, duration: float, job_reward: int) -> void:
	is_working = true
	current_job_id = job_id
	work_time = 0.0
	work_duration = duration
	reward = job_reward

func reset() -> void:
	is_working = false
	current_job_id = -1
	work_time = 0.0
	work_duration = 0.0
	reward = 0

func get_progress() -> float:
	if work_duration <= 0:
		return 0.0
	return clamp(work_time / work_duration, 0.0, 1.0)
