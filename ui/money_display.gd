class_name MoneyDisplay
extends Control

## Displays player's current money

var panel: PanelContainer
var label: Label
var amount: int = 0

func _ready() -> void:
	custom_minimum_size = Vector2(150, 50)
	_create_ui()

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.15, 0.1, 0.85)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.6, 0.3)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)

	# Dollar sign
	var dollar = Label.new()
	dollar.text = "$"
	dollar.add_theme_font_size_override("font_size", 24)
	dollar.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	hbox.add_child(dollar)

	# Amount
	label = Label.new()
	label.text = "0"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label)

func set_amount(value: int) -> void:
	amount = value
	if label:
		label.text = str(amount)

func add_amount(value: int) -> void:
	set_amount(amount + value)
