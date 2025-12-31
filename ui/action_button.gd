class_name ActionButton
extends Control

## Action button for interacting with workstations

signal action_pressed

var button: Button
var is_enabled: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(80, 80)

	button = Button.new()
	button.text = "ACT"
	button.custom_minimum_size = Vector2(80, 80)
	button.size = Vector2(80, 80)
	button.pressed.connect(_on_pressed)

	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.7, 0.3, 0.8)
	style.corner_radius_top_left = 40
	style.corner_radius_top_right = 40
	style.corner_radius_bottom_left = 40
	style.corner_radius_bottom_right = 40
	button.add_theme_stylebox_override("normal", style)

	var style_disabled = StyleBoxFlat.new()
	style_disabled.bg_color = Color(0.3, 0.3, 0.3, 0.5)
	style_disabled.corner_radius_top_left = 40
	style_disabled.corner_radius_top_right = 40
	style_disabled.corner_radius_bottom_left = 40
	style_disabled.corner_radius_bottom_right = 40
	button.add_theme_stylebox_override("disabled", style_disabled)

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.15, 0.5, 0.2, 0.9)
	style_pressed.corner_radius_top_left = 40
	style_pressed.corner_radius_top_right = 40
	style_pressed.corner_radius_bottom_left = 40
	style_pressed.corner_radius_bottom_right = 40
	button.add_theme_stylebox_override("pressed", style_pressed)

	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)

	add_child(button)
	set_enabled(false)

func _on_pressed() -> void:
	if is_enabled:
		action_pressed.emit()

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	button.disabled = not enabled
