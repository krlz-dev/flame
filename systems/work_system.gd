class_name WorkSystem
extends System

## Processes work/job progress and rewards

signal work_started(job_id: int)
signal work_progress(progress: float)
signal work_completed(reward: int)
signal hacking_started()
signal hacking_completed(reward: int)

var player: Node = null
var bot_running: bool = false
var bot_delay_timer: float = 0.0
const BOT_DELAY = 1.0  # Delay between hacking jobs (prevents movement)

# Job definitions: [duration, reward]
const JOBS = {
	1: {"name": "Job 1 - Heavy Work", "duration": 10.0, "reward": 50},
	2: {"name": "Job 2 - Medium Work", "duration": 5.0, "reward": 3},
	3: {"name": "Job 3 - Quick Task", "duration": 3.0, "reward": 1}
}

# Hacking mode settings
const HACKING_DURATION = 2.0  # 2 seconds per hack
const HACKING_MIN_REWARD = 10000
const HACKING_MAX_REWARD = 50000

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

func start_bot() -> void:
	bot_running = true
	_start_hacking()

func stop_bot() -> void:
	bot_running = false

func is_bot_running() -> bool:
	return bot_running

func _start_hacking() -> void:
	if not player or not player.has_meta("work"):
		return

	var work_comp: WorkComponent = player.get_meta("work")
	# Random reward between 10,000 and 50,000
	var random_reward = randi_range(HACKING_MIN_REWARD, HACKING_MAX_REWARD)
	work_comp.start_job(-1, HACKING_DURATION, random_reward)  # job_id -1 for hacking
	hacking_started.emit()

func cancel_job() -> void:
	if not player or not player.has_meta("work"):
		return
	var work_comp: WorkComponent = player.get_meta("work")
	work_comp.reset()

func process_system(delta: float) -> void:
	if not player or not player.has_meta("work"):
		return

	# Handle bot delay timer
	if bot_running and bot_delay_timer > 0:
		bot_delay_timer -= delta
		if bot_delay_timer <= 0:
			_start_hacking()
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
	var was_hacking = work_comp.current_job_id == -1

	# Add money to player
	if player.has_meta("money"):
		var money_comp: MoneyComponent = player.get_meta("money")
		money_comp.amount += reward

	if was_hacking:
		hacking_completed.emit(reward)
	else:
		work_completed.emit(reward)

	work_comp.reset()

	# If bot is running, start next hacking job after short delay
	if bot_running:
		bot_delay_timer = BOT_DELAY

func is_working() -> bool:
	# Also return true during bot delay to prevent movement between hacks
	if bot_running and bot_delay_timer > 0:
		return true
	if not player or not player.has_meta("work"):
		return false
	var work_comp: WorkComponent = player.get_meta("work")
	return work_comp.is_working

func get_job_info(job_id: int) -> Dictionary:
	if JOBS.has(job_id):
		return JOBS[job_id]
	return {}
