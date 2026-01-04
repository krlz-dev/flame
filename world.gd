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
@onready var job_menu: JobMenu = $CanvasLayer/UI/JobMenu
@onready var progress_bar: WorkProgressBar = $CanvasLayer/UI/ProgressBar
@onready var money_display: MoneyDisplay = $CanvasLayer/UI/MoneyDisplay
@onready var win_screen: WinScreen = $CanvasLayer/UI/WinScreen
var action_button: ActionButton

# Dialog for milestones
var dialog_container: Control
var dialog_box: DialogBox
var architect_portrait: Texture2D

var game_won: bool = false
var milestone_reached: bool = false
var bot_unlocked: bool = false

# Interaction indicator
var interaction_indicator: Label
var can_interact: bool = false
var indicator_tween: Tween

func _ready() -> void:
	# Enable Y-sorting for proper depth ordering
	y_sort_enabled = true

	_setup_systems()
	_create_entities()
	_setup_interaction_indicator()
	_setup_action_button()
	_setup_lighting()
	_setup_dialog()
	_connect_signals()

func _setup_lighting() -> void:
	# Darken the entire scene
	var canvas_modulate = CanvasModulate.new()
	canvas_modulate.color = Color(0.15, 0.15, 0.2)  # Dark blue-ish tint
	add_child(canvas_modulate)

	# Create PC screen light
	var pc_light = PointLight2D.new()
	pc_light.position = workstation.position + Vector2(0, -20)  # Slightly above desk
	pc_light.color = Color(0.6, 0.8, 1.0)  # Cool monitor blue
	pc_light.energy = 1.5
	pc_light.texture = _create_light_texture()
	pc_light.texture_scale = 4.0  # Large enough to see around
	pc_light.blend_mode = PointLight2D.BLEND_MODE_ADD
	add_child(pc_light)

func _create_light_texture() -> Texture2D:
	# Create a radial gradient texture for the light
	var image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var center = Vector2(64, 64)

	for x in range(128):
		for y in range(128):
			var dist = Vector2(x, y).distance_to(center) / 64.0
			var alpha = clamp(1.0 - dist, 0.0, 1.0)
			alpha = alpha * alpha  # Quadratic falloff for softer edges
			image.set_pixel(x, y, Color(1, 1, 1, alpha))

	return ImageTexture.create_from_image(image)

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

func _create_floor() -> void:
	# Create tiled floor using garage tileset (4x4 grid = 16 tiles)
	var floor_texture = load("res://assets/props/garage_floor_tileset.png")
	if not floor_texture:
		return

	var floor_container = Node2D.new()
	floor_container.name = "Floor"
	floor_container.z_index = -10
	add_child(floor_container)

	# Tileset is 4x4 grid (16 tiles), each tile is 32x32
	var grid_cols = 4
	var grid_rows = 4
	var tile_size = Vector2(32, 32)

	# Stage bounds (narrower, positioned lower)
	var stage_width = 600
	var stage_height = 550
	var stage_offset_x = 60
	var stage_offset_y = 250
	var tiles_x = int(ceil(stage_width / tile_size.x))
	var tiles_y = int(ceil(stage_height / tile_size.y))

	# Use various tiles for natural variation
	var floor_tiles = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

	# Seed for consistent but varied pattern
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345

	for y in range(tiles_y):
		for x in range(tiles_x):
			var sprite = Sprite2D.new()
			sprite.texture = floor_texture
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

			# Pick a random tile for natural variation
			var tile_idx = floor_tiles[rng.randi() % floor_tiles.size()]
			var tile_x = tile_idx % grid_cols
			var tile_y = tile_idx / grid_cols

			sprite.region_enabled = true
			sprite.region_rect = Rect2(tile_x * tile_size.x, tile_y * tile_size.y, tile_size.x, tile_size.y)
			sprite.position = Vector2(stage_offset_x + x * tile_size.x + tile_size.x / 2, stage_offset_y + y * tile_size.y + tile_size.y / 2)
			floor_container.add_child(sprite)

func _create_entities() -> void:
	# Create tiled floor background
	_create_floor()

	# Stage bounds for positioning (narrower, lower on screen)
	var stage_x = 60
	var stage_y = 250
	var stage_w = 600
	var stage_h = 550
	var center_x = stage_x + stage_w / 2  # 360

	# Create player at center
	player = EntityFactory.create_player(Vector2(center_x, stage_y + 380))
	add_child(player)
	input_system.set_target(player)
	interaction_system.set_player(player)
	work_system.set_player(player)

	# Create workstation (desk with PC)
	workstation = EntityFactory.create_workstation(Vector2(center_x, stage_y + 150))
	add_child(workstation)

	# Create garage props - two shelving units
	var shelving1 = EntityFactory.create_shelving(Vector2(stage_x + 100, stage_y + 60))
	add_child(shelving1)

	var shelving2 = EntityFactory.create_shelving(Vector2(stage_x + stage_w - 100, stage_y + 60))
	add_child(shelving2)

	var cables1 = EntityFactory.create_cables(Vector2(stage_x + 140, stage_y + 280))
	add_child(cables1)

	var cables2 = EntityFactory.create_cables(Vector2(stage_x + stage_w - 140, stage_y + 320))
	add_child(cables2)

	# Create walls with collision offsets (top extends down, bottom extends up)
	var top_wall = EntityFactory.create_wall(Vector2(center_x, stage_y), Vector2(stage_w, 20), Vector2(0, 20))
	var bottom_wall = EntityFactory.create_wall(Vector2(center_x, stage_y + stage_h + 25), Vector2(stage_w, 20), Vector2(0, 40))
	var left_wall = EntityFactory.create_wall(Vector2(stage_x, stage_y + stage_h / 2 + 12), Vector2(20, stage_h + 40))
	var right_wall = EntityFactory.create_wall(Vector2(stage_x + stage_w, stage_y + stage_h / 2 + 12), Vector2(20, stage_h + 40))

	add_child(top_wall)
	add_child(bottom_wall)
	add_child(left_wall)
	add_child(right_wall)

func _setup_interaction_indicator() -> void:
	# Create "!" indicator above workstation
	interaction_indicator = Label.new()
	interaction_indicator.text = "!"
	interaction_indicator.add_theme_font_size_override("font_size", 48)
	interaction_indicator.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	interaction_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_indicator.position = workstation.position + Vector2(-5, -100)
	interaction_indicator.visible = false
	interaction_indicator.modulate.a = 0.0
	interaction_indicator.z_index = 100
	interaction_indicator.pivot_offset = Vector2(15, 24)  # Center pivot for shake
	add_child(interaction_indicator)

func _setup_action_button() -> void:
	# Create pixel art Enter key action button in bottom-right corner
	# Button is 128x128 scaled to 0.75 = 96x96 display size
	action_button = ActionButton.new()
	action_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_button.anchor_left = 1.0
	action_button.anchor_top = 1.0
	action_button.anchor_right = 1.0
	action_button.anchor_bottom = 1.0
	action_button.offset_left = -126  # 96 (button) + 30 margin
	action_button.offset_top = -136   # 96 (button) + 40 margin from bottom
	action_button.offset_right = -30
	action_button.offset_bottom = -40
	action_button.action_pressed.connect(_on_action_button_pressed)
	$CanvasLayer/UI.add_child(action_button)

func _show_indicator() -> void:
	if indicator_tween:
		indicator_tween.kill()
	interaction_indicator.visible = true
	indicator_tween = create_tween()
	indicator_tween.tween_property(interaction_indicator, "modulate:a", 1.0, 0.3)

func _hide_indicator() -> void:
	if indicator_tween:
		indicator_tween.kill()
	indicator_tween = create_tween()
	indicator_tween.tween_property(interaction_indicator, "modulate:a", 0.0, 0.3)
	indicator_tween.tween_callback(func(): interaction_indicator.visible = false)

func _shake_indicator() -> void:
	var shake_tween = create_tween()
	var original_pos = workstation.position + Vector2(-5, -100)
	shake_tween.tween_property(interaction_indicator, "position", original_pos + Vector2(-5, 0), 0.05)
	shake_tween.tween_property(interaction_indicator, "position", original_pos + Vector2(5, 0), 0.05)
	shake_tween.tween_property(interaction_indicator, "position", original_pos + Vector2(-3, 0), 0.05)
	shake_tween.tween_property(interaction_indicator, "position", original_pos + Vector2(3, 0), 0.05)
	shake_tween.tween_property(interaction_indicator, "position", original_pos, 0.05)

func _connect_signals() -> void:
	# Joystick
	joystick.input_changed.connect(_on_joystick_input)

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
	# Show/hide interaction indicator and enable/disable action button based on proximity
	if not work_system.is_working():
		can_interact = is_near
		action_button.set_enabled(is_near)
		if is_near:
			_show_indicator()
		else:
			_hide_indicator()

func _on_action_button_pressed() -> void:
	# Trigger workstation interaction when Enter button is pressed
	if can_interact and not work_system.is_working():
		_shake_indicator()
		job_menu.show_menu()


func _on_job_selected(job_id: int) -> void:
	# Start the selected job
	work_system.start_job(job_id)

func _on_bot_selected() -> void:
	# Start the bot auto-loop
	work_system.start_bot()
	can_interact = false
	_hide_indicator()

func _on_bot_loop_tick(job_id: int) -> void:
	# Update progress bar with current bot job
	var job_info = work_system.get_job_info(job_id)
	progress_bar.show_bar("BOT: " + job_info.get("name", "Working"))

func _on_work_started(job_id: int) -> void:
	var job_info = work_system.get_job_info(job_id)
	progress_bar.show_bar(job_info.get("name", "Working"))
	_hide_indicator()
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

	# Re-enable interaction if still near workstation (and not botting)
	if not work_system.is_bot_running():
		var nearby = interaction_system.get_nearby_workstation()
		can_interact = nearby != null
		action_button.set_enabled(can_interact)
		if nearby:
			_show_indicator()

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

	# Re-enable interaction if still near workstation
	var nearby = interaction_system.get_nearby_workstation()
	can_interact = nearby != null
	action_button.set_enabled(can_interact)
	if nearby:
		_show_indicator()

func _physics_process(delta: float) -> void:
	for system in systems:
		system.process_system(delta)
