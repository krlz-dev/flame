class_name WorkSystem
extends System

## Processes work/job progress and rewards

signal work_started(job_id: int)
signal work_progress(progress: float)
signal work_completed(reward: int)

var player: Node = null

# Job definitions: [duration, reward]
const JOBS = {
	1: {"name": "Job 1 - Heavy Work", "duration": 10.0, "reward": 50},
	2: {"name": "Job 2 - Medium Work", "duration": 5.0, "reward": 3},
	3: {"name": "Job 3 - Quick Task", "duration": 3.0, "reward": 1}
}

func set_player(p: Node) -> void:
	player = p

func start_job(job_id: int) -> bool:
	if not player or not player.has_meta("work"):
		return false

	var work_comp: WorkComponent = player.get_meta("work")
	if work_comp.is_working:
		return false

	if not JOBS.has(job_id):
		return false

	var job = JOBS[job_id]
	work_comp.start_job(job_id, job.duration, job.reward)
	work_started.emit(job_id)
	return true

func cancel_job() -> void:
	if not player or not player.has_meta("work"):
		return
	var work_comp: WorkComponent = player.get_meta("work")
	work_comp.reset()

func process_system(delta: float) -> void:
	if not player or not player.has_meta("work"):
		return

	var work_comp: WorkComponent = player.get_meta("work")
	if not work_comp.is_working:
		return

	work_comp.work_time += delta
	work_progress.emit(work_comp.get_progress())

	# Check if work is complete
	if work_comp.work_time >= work_comp.work_duration:
		_complete_work(work_comp)

func _complete_work(work_comp: WorkComponent) -> void:
	var reward = work_comp.reward

	# Add money to player
	if player.has_meta("money"):
		var money_comp: MoneyComponent = player.get_meta("money")
		money_comp.amount += reward

	work_completed.emit(reward)
	work_comp.reset()

func is_working() -> bool:
	if not player or not player.has_meta("work"):
		return false
	var work_comp: WorkComponent = player.get_meta("work")
	return work_comp.is_working

func get_job_info(job_id: int) -> Dictionary:
	if JOBS.has(job_id):
		return JOBS[job_id]
	return {}
