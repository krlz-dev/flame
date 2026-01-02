extends Node2D

## ECS World - manages all entities and systems

const GOAL_AMOUNT = 1_000_000
const MILESTONE_AMOUNT = 100

# Systems
var systems: Array[System] = []
var input_system: InputSystem
var movement_system: MovementSystem
var interaction_system: InteractionSystem
var work_system: WorkSystem
var animation_system: AnimationSystem

# Entities
var player: CharacterBody2D
var workstation: StaticBody2D

# UI References
@onready var joystick: Joystick = $CanvasLayer/UI/Joystick
@onready var action_button: ActionButton = $CanvasLayer/UI/ActionButton
@onready var job_menu: JobMenu = $CanvasLayer/UI/JobMenu
@onready var progress_bar: WorkProgressBar = $CanvasLayer/UI/ProgressBar
@onready var money_display: MoneyDisplay = $CanvasLayer/UI/MoneyDisplay
@onready var win_screen: WinScreen = $CanvasLayer/UI/WinScreen

# Dialog for milestones
var dialog_container: Control
var dialog_box: DialogBox
var architect_portrait: Texture2D

var game_won: bool = false
var milestone_reached: bool = false
var bot_unlocked: bool = false

func _ready() -> void:
	# Enable Y-sorting for proper depth ordering
	y_sort_enabled = true

	_setup_systems()
	_create_entities()
	_setup_dialog()
	_connect_signals()

func _setup_dialog() -> void:
	# Load architect portrait
	architect_portrait = load("res://assets/npc/architect_portrait.png")

	# Create dialog container with dark background (like intro scene)
	dialog_container = Control.new()
	dialog_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog_container.visible = false
	$CanvasLayer.add_child(dialog_container)

	# Dark background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog_container.add_child(bg)

	# Create dialog box for milestone dialogs
	dialog_box = DialogBox.new()
	dialog_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog_container.add_child(dialog_box)
	dialog_box.dialog_finished.connect(_on_milestone_dialog_finished)

func _setup_systems() -> void:
	input_system = InputSystem.new(self)
	movement_system = MovementSystem.new(self)
	interaction_system = InteractionSystem.new(self)
	work_system = WorkSystem.new(self)
	animation_system = AnimationSystem.new(self)

	systems.append(input_system)
	systems.append(movement_system)
	systems.append(interaction_system)
	systems.append(work_system)
	systems.append(animation_system)

func _create_entities() -> void:
	# Create player at center
	player = EntityFactory.create_player(Vector2(360, 600))
	add_child(player)
	input_system.set_target(player)
	interaction_system.set_player(player)
	work_system.set_player(player)

	# Create workstation (desk with PC) - position is visual center for Y-sort
	workstation = EntityFactory.create_workstation(Vector2(360, 320))
	add_child(workstation)

	# Create garage props
	var old_car = EntityFactory.create_old_car(Vector2(580, 750))
	add_child(old_car)

	var shelving = EntityFactory.create_shelving(Vector2(120, 200))
	add_child(shelving)

	var cables1 = EntityFactory.create_cables(Vector2(250, 450))
	add_child(cables1)

	var cables2 = EntityFactory.create_cables(Vector2(500, 550))
	add_child(cables2)

	# Create walls
	var top_wall = EntityFactory.create_wall(Vector2(360, 10), Vector2(720, 20))
	var bottom_wall = EntityFactory.create_wall(Vector2(360, 1080), Vector2(720, 20))
	var left_wall = EntityFactory.create_wall(Vector2(10, 545), Vector2(20, 1070))
	var right_wall = EntityFactory.create_wall(Vector2(710, 545), Vector2(20, 1070))

	add_child(top_wall)
	add_child(bottom_wall)
	add_child(left_wall)
	add_child(right_wall)

func _connect_signals() -> void:
	# Joystick
	joystick.input_changed.connect(_on_joystick_input)

	# Action button
	action_button.action_pressed.connect(_on_action_pressed)

	# Interaction system
	interaction_system.player_near_workstation.connect(_on_player_near_workstation)

	# Job menu
	job_menu.job_selected.connect(_on_job_selected)
	job_menu.bot_selected.connect(_on_bot_selected)

	# Work system
	work_system.work_started.connect(_on_work_started)
	work_system.work_progress.connect(_on_work_progress)
	work_system.work_completed.connect(_on_work_completed)
	work_system.bot_loop_tick.connect(_on_bot_loop_tick)

func _on_joystick_input(direction: Vector2) -> void:
	# Disable movement while working
	if work_system.is_working():
		input_system.receive_input(Vector2.ZERO)
	else:
		input_system.receive_input(direction)

func _on_player_near_workstation(_workstation: Node, is_near: bool) -> void:
	# Enable/disable action button based on proximity
	if not work_system.is_working():
		action_button.set_enabled(is_near)

func _on_action_pressed() -> void:
	# Show job menu when action is pressed
	if interaction_system.get_nearby_workstation():
		job_menu.show_menu()

func _on_job_selected(job_id: int) -> void:
	# Start the selected job
	work_system.start_job(job_id)

func _on_bot_selected() -> void:
	# Start the bot auto-loop
	work_system.start_bot()
	action_button.set_enabled(false)

func _on_bot_loop_tick(job_id: int) -> void:
	# Update progress bar with current bot job
	var job_info = work_system.get_job_info(job_id)
	progress_bar.show_bar("BOT: " + job_info.get("name", "Working"))

func _on_work_started(job_id: int) -> void:
	var job_info = work_system.get_job_info(job_id)
	progress_bar.show_bar(job_info.get("name", "Working"))
	action_button.set_enabled(false)

func _on_work_progress(progress: float) -> void:
	progress_bar.set_progress(progress)

func _on_work_completed(reward: int) -> void:
	# Don't hide progress bar if bot is running (it will show next job)
	if not work_system.is_bot_running():
		progress_bar.hide_bar()

	# Update money display and check win condition
	if player.has_meta("money"):
		var money_comp: MoneyComponent = player.get_meta("money")
		money_display.set_amount(money_comp.amount)

		# Check for win
		if money_comp.amount >= GOAL_AMOUNT and not game_won:
			game_won = true
			work_system.stop_bot()  # Stop bot on win
			progress_bar.hide_bar()
			win_screen.show_win()
			return

		# Check for $100 milestone - unlock bot
		if money_comp.amount >= MILESTONE_AMOUNT and not milestone_reached:
			milestone_reached = true
			_show_milestone_dialog()
			return

	# Re-enable action button if still near workstation (and not botting)
	if not work_system.is_bot_running():
		var nearby = interaction_system.get_nearby_workstation()
		action_button.set_enabled(nearby != null)

func _show_milestone_dialog() -> void:
	var lines: Array[String] = [
		"Well, well... $100 already.",
		"At this pace, you'll reach a million in about... *calculates*",
		"...roughly 10,000 more work sessions. Give or take.",
		"That's assuming you don't sleep. Or eat. Or blink.",
		"But there might be... another way.",
		"What if I told you the system has certain... exploitable patterns?",
		"I've unlocked something for you. Check your job menu.",
		"'Create Bot Script' - it automates the grind. Faster. Smarter.",
		"Use it wisely. Or recklessly. I'm not your supervisor."
	]
	dialog_container.visible = true
	dialog_box.start_dialog(lines, architect_portrait, "The Architect")

func _on_milestone_dialog_finished() -> void:
	dialog_container.visible = false
	bot_unlocked = true
	job_menu.unlock_bot()

	# Re-enable action button if still near workstation
	var nearby = interaction_system.get_nearby_workstation()
	action_button.set_enabled(nearby != null)

func _physics_process(delta: float) -> void:
	for system in systems:
		system.process_system(delta)
