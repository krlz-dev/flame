class_name WinScreen
extends Control

## Victory screen when player reaches $1,000,000

signal play_again
signal main_menu

func _ready() -> void:
	visible = false
	_create_ui()

func _create_ui() -> void:
	# Background overlay
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Center container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.15, 0.1)
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.7, 0.3)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)
	margin.add_child(vbox)

	# Trophy icon (text-based)
	var trophy = Label.new()
	trophy.text = "WINNER"
	trophy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trophy.add_theme_font_size_override("font_size", 48)
	trophy.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	vbox.add_child(trophy)

	# Congratulations
	var congrats = Label.new()
	congrats.text = "CONGRATULATIONS!"
	congrats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	congrats.add_theme_font_size_override("font_size", 32)
	congrats.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	vbox.add_child(congrats)

	# Message
	var message = Label.new()
	message.text = "You earned $1,000,000!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 22)
	message.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	vbox.add_child(message)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	# Buttons container
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 20)
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_container)

	# Play Again button
	var play_btn = _create_button("PLAY AGAIN", Color(0.2, 0.5, 0.3))
	play_btn.pressed.connect(_on_play_again)
	btn_container.add_child(play_btn)

	# Menu button
	var menu_btn = _create_button("MAIN MENU", Color(0.4, 0.4, 0.5))
	menu_btn.pressed.connect(_on_main_menu)
	btn_container.add_child(menu_btn)

func _create_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 50)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)

	var hover = StyleBoxFlat.new()
	hover.bg_color = color.lightened(0.15)
	hover.corner_radius_top_left = 8
	hover.corner_radius_top_right = 8
	hover.corner_radius_bottom_left = 8
	hover.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color.WHITE)

	return btn

func show_win() -> void:
	visible = true

func _on_play_again() -> void:
	play_again.emit()
	get_tree().reload_current_scene()

func _on_main_menu() -> void:
	main_menu.emit()
	get_tree().change_scene_to_file("res://menu.tscn")
