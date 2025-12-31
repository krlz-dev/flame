extends Node2D

## ECS World - manages all entities and systems

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

func _ready() -> void:
	_setup_systems()
	_create_entities()
	_connect_signals()

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

	# Create workstation (desk with PC)
	workstation = EntityFactory.create_workstation(Vector2(360, 280))
	add_child(workstation)

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

	# Work system
	work_system.work_started.connect(_on_work_started)
	work_system.work_progress.connect(_on_work_progress)
	work_system.work_completed.connect(_on_work_completed)

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

func _on_work_started(job_id: int) -> void:
	var job_info = work_system.get_job_info(job_id)
	progress_bar.show_bar(job_info.get("name", "Working"))
	action_button.set_enabled(false)

func _on_work_progress(progress: float) -> void:
	progress_bar.set_progress(progress)

func _on_work_completed(reward: int) -> void:
	progress_bar.hide_bar()

	# Update money display
	if player.has_meta("money"):
		var money_comp: MoneyComponent = player.get_meta("money")
		money_display.set_amount(money_comp.amount)

	# Re-enable action button if still near workstation
	var nearby = interaction_system.get_nearby_workstation()
	action_button.set_enabled(nearby != null)

func _physics_process(delta: float) -> void:
	for system in systems:
		system.process_system(delta)
