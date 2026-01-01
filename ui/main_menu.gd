class_name MainMenu
extends Control

## Main menu screen

const GOAL_AMOUNT = 1_000_000

func _ready() -> void:
	_create_ui()

func _create_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	center.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "FLAME"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	vbox.add_child(title)

	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Work Simulator"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(subtitle)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)

	# Goal info
	var goal_label = Label.new()
	goal_label.text = "Goal: Earn $%s" % _format_money(GOAL_AMOUNT)
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_label.add_theme_font_size_override("font_size", 20)
	goal_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	vbox.add_child(goal_label)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer2)

	# Start button
	var start_btn = Button.new()
	start_btn.text = "START GAME"
	start_btn.custom_minimum_size = Vector2(250, 70)
	start_btn.pressed.connect(_on_start_pressed)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.5, 0.3)
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color(0.15, 0.35, 0.2)
	start_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.25, 0.6, 0.35)
	btn_hover.corner_radius_top_left = 12
	btn_hover.corner_radius_top_right = 12
	btn_hover.corner_radius_bottom_left = 12
	btn_hover.corner_radius_bottom_right = 12
	btn_hover.border_width_bottom = 4
	btn_hover.border_color = Color(0.18, 0.4, 0.25)
	start_btn.add_theme_stylebox_override("hover", btn_hover)

	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color(0.15, 0.4, 0.25)
	btn_pressed.corner_radius_top_left = 12
	btn_pressed.corner_radius_top_right = 12
	btn_pressed.corner_radius_bottom_left = 12
	btn_pressed.corner_radius_bottom_right = 12
	start_btn.add_theme_stylebox_override("pressed", btn_pressed)

	start_btn.add_theme_font_size_override("font_size", 28)
	start_btn.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(start_btn)

	# Version
	var version = Label.new()
	version.text = "v0.1.0"
	version.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	version.position = Vector2(-70, -40)
	version.add_theme_font_size_override("font_size", 14)
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	add_child(version)

func _format_money(amount: int) -> String:
	var s = str(amount)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://intro.tscn")
