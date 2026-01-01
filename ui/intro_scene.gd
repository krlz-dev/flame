class_name IntroScene
extends Control

## Intro scene with The Architect dialog

var dialog_box: DialogBox
var portrait: Texture2D

func _ready() -> void:
	_create_ui()
	_start_intro()

func _create_ui() -> void:
	# Dark background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Dialog box
	dialog_box = DialogBox.new()
	dialog_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog_box.dialog_finished.connect(_on_dialog_finished)
	add_child(dialog_box)

func _start_intro() -> void:
	# Load portrait
	portrait = load("res://assets/npc/architect_portrait.png")

	# The story dialog
	var lines: Array[String] = [
		"Ah... you're finally awake.",
		"I am The Architect. I've been watching you for some time now.",
		"This world... it runs on money. Cold, digital currency flowing through the veins of society.",
		"You've been chosen for something greater. But first, you must prove yourself.",
		"There's a terminal ahead. Use it. Work. Earn.",
		"Your goal: One million dollars. Only then will the truth reveal itself.",
		"The path won't be easy. Each job pays differently. Choose wisely.",
		"Remember... I'll be watching. The system is always watching.",
		"Now go. Your destiny awaits at that workstation.",
	]

	dialog_box.start_dialog(lines, portrait, "The Architect")

func _on_dialog_finished() -> void:
	# Transition to main game
	get_tree().change_scene_to_file("res://main.tscn")
