class_name DialogBox
extends Control

## RPG-style dialog box with portrait and typewriter effect

signal dialog_finished

const CHAR_DELAY = 0.03  # Time between characters

var dialog_lines: Array[String] = []
var current_line: int = 0
var current_char: int = 0
var is_typing: bool = false
var can_advance: bool = false

var portrait_texture: Texture2D
var speaker_name: String = "???"

# UI elements
var portrait_sprite: TextureRect
var name_label: Label
var text_label: Label
var continue_indicator: Label
var char_timer: Timer

func _ready() -> void:
	visible = false
	_create_ui()

func _create_ui() -> void:
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Dialog panel at bottom
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -220
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_bottom = -20

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.3, 0.5, 0.7)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Portrait container with border
	var portrait_panel = PanelContainer.new()
	portrait_panel.custom_minimum_size = Vector2(140, 140)

	var portrait_style = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.05, 0.05, 0.08)
	portrait_style.corner_radius_top_left = 8
	portrait_style.corner_radius_top_right = 8
	portrait_style.corner_radius_bottom_left = 8
	portrait_style.corner_radius_bottom_right = 8
	portrait_style.border_width_left = 2
	portrait_style.border_width_right = 2
	portrait_style.border_width_top = 2
	portrait_style.border_width_bottom = 2
	portrait_style.border_color = Color(0.4, 0.6, 0.8)
	portrait_panel.add_theme_stylebox_override("panel", portrait_style)
	hbox.add_child(portrait_panel)

	var portrait_center = CenterContainer.new()
	portrait_panel.add_child(portrait_center)

	portrait_sprite = TextureRect.new()
	portrait_sprite.custom_minimum_size = Vector2(128, 128)
	portrait_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait_center.add_child(portrait_sprite)

	# Text container
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(text_vbox)

	# Speaker name
	name_label = Label.new()
	name_label.text = speaker_name
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	text_vbox.add_child(name_label)

	# Dialog text
	text_label = Label.new()
	text_label.text = ""
	text_label.add_theme_font_size_override("font_size", 18)
	text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.custom_minimum_size = Vector2(0, 80)
	text_vbox.add_child(text_label)

	# Continue indicator
	continue_indicator = Label.new()
	continue_indicator.text = "Tap to continue..."
	continue_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	continue_indicator.add_theme_font_size_override("font_size", 14)
	continue_indicator.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	continue_indicator.visible = false
	text_vbox.add_child(continue_indicator)

	# Timer for typewriter effect
	char_timer = Timer.new()
	char_timer.wait_time = CHAR_DELAY
	char_timer.timeout.connect(_on_char_timer)
	add_child(char_timer)

func start_dialog(lines: Array[String], portrait: Texture2D, name: String) -> void:
	dialog_lines = lines
	portrait_texture = portrait
	speaker_name = name
	current_line = 0

	portrait_sprite.texture = portrait_texture
	name_label.text = speaker_name

	visible = true
	_start_line()

func _start_line() -> void:
	if current_line >= dialog_lines.size():
		_end_dialog()
		return

	text_label.text = ""
	current_char = 0
	is_typing = true
	can_advance = false
	continue_indicator.visible = false
	char_timer.start()

func _on_char_timer() -> void:
	if current_char < dialog_lines[current_line].length():
		text_label.text += dialog_lines[current_line][current_char]
		current_char += 1
	else:
		char_timer.stop()
		is_typing = false
		can_advance = true
		continue_indicator.visible = true

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch and event.pressed:
		_handle_advance()
	elif event is InputEventMouseButton and event.pressed:
		_handle_advance()

func _handle_advance() -> void:
	if is_typing:
		# Skip to end of current line
		char_timer.stop()
		text_label.text = dialog_lines[current_line]
		is_typing = false
		can_advance = true
		continue_indicator.visible = true
	elif can_advance:
		current_line += 1
		_start_line()

func _end_dialog() -> void:
	visible = false
	dialog_finished.emit()
