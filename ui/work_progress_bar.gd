class_name WorkProgressBar
extends Control

## Progress bar for showing work/job progress

var background: ColorRect
var fill: ColorRect
var label: Label
var panel: PanelContainer
var panel_style: StyleBoxFlat

var progress: float = 0.0
var is_hacking: bool = false

const NORMAL_COLOR = Color(0.3, 0.7, 0.4)  # Green
const HACKING_COLOR = Color(0.6, 0.2, 0.8)  # Purple
const NORMAL_BORDER = Color(0.3, 0.5, 0.7)  # Blue
const HACKING_BORDER = Color(0.8, 0.3, 0.9)  # Purple border

func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(250, 60)
	_create_ui()

func _create_ui() -> void:
	# Panel container
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = NORMAL_BORDER
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	# Label
	label = Label.new()
	label.text = "WORKING..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
	vbox.add_child(label)

	# Progress bar container
	var bar_container = Control.new()
	bar_container.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(bar_container)

	# Background
	background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.25)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar_container.add_child(background)

	# Fill
	fill = ColorRect.new()
	fill.color = Color(0.3, 0.7, 0.4)
	fill.anchor_top = 0
	fill.anchor_bottom = 1
	fill.anchor_left = 0
	fill.anchor_right = 0
	fill.offset_right = 0
	bar_container.add_child(fill)

func set_progress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	if fill:
		fill.anchor_right = progress
	if label:
		var status_text = "HACKING" if is_hacking else "WORKING"
		label.text = "%s... %d%%" % [status_text, int(progress * 100)]

func show_bar(job_name: String = "WORKING") -> void:
	if label:
		label.text = "%s... 0%%" % job_name.to_upper()
	set_progress(0)
	visible = true

func show_hacking() -> void:
	is_hacking = true
	if fill:
		fill.color = HACKING_COLOR
	if panel_style:
		panel_style.border_color = HACKING_BORDER
	if label:
		label.text = "HACKING... 0%%"
	set_progress(0)
	visible = true

func hide_bar() -> void:
	visible = false
	# Reset to normal mode
	is_hacking = false
	if fill:
		fill.color = NORMAL_COLOR
	if panel_style:
		panel_style.border_color = NORMAL_BORDER
