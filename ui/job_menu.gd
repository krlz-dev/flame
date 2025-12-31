class_name JobMenu
extends Control

## Job selection menu UI

signal job_selected(job_id: int)
signal menu_closed

var panel: PanelContainer
var vbox: VBoxContainer
var title_label: Label
var job_buttons: Array[Button] = []
var close_button: Button

const JOBS = {
	1: {"name": "Heavy Work", "time": "10s", "reward": "$50"},
	2: {"name": "Medium Work", "time": "5s", "reward": "$3"},
	3: {"name": "Quick Task", "time": "3s", "reward": "$1"}
}

func _ready() -> void:
	visible = false
	_create_ui()

func _create_ui() -> void:
	# Background dimmer
	var dimmer = ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.5)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.gui_input.connect(_on_dimmer_input)
	add_child(dimmer)

	# Center container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# Panel
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 350)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.4, 0.4, 0.5)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	# VBox
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "SELECT JOB"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	vbox.add_child(title_label)

	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Job buttons
	for job_id in JOBS:
		var job = JOBS[job_id]
		var btn = _create_job_button(job_id, job.name, job.time, job.reward)
		vbox.add_child(btn)
		job_buttons.append(btn)

	# Close button
	close_button = Button.new()
	close_button.text = "CANCEL"
	close_button.custom_minimum_size = Vector2(0, 45)
	close_button.pressed.connect(_on_close_pressed)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.5, 0.2, 0.2, 0.8)
	close_style.corner_radius_top_left = 8
	close_style.corner_radius_top_right = 8
	close_style.corner_radius_bottom_left = 8
	close_style.corner_radius_bottom_right = 8
	close_button.add_theme_stylebox_override("normal", close_style)
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color.WHITE)

	vbox.add_child(close_button)

func _create_job_button(job_id: int, job_name: String, time: String, reward: String) -> Button:
	var btn = Button.new()
	btn.text = "%s\n%s - %s" % [job_name, time, reward]
	btn.custom_minimum_size = Vector2(0, 60)
	btn.pressed.connect(_on_job_pressed.bind(job_id))

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.4, 0.6, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.25, 0.5, 0.7, 0.9)
	style_hover.corner_radius_top_left = 8
	style_hover.corner_radius_top_right = 8
	style_hover.corner_radius_bottom_left = 8
	style_hover.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color.WHITE)

	return btn

func _on_job_pressed(job_id: int) -> void:
	job_selected.emit(job_id)
	hide_menu()

func _on_close_pressed() -> void:
	menu_closed.emit()
	hide_menu()

func _on_dimmer_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		menu_closed.emit()
		hide_menu()

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
