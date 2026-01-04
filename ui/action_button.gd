class_name ActionButton
extends Control

## Pixel art Enter key button for interacting with workstations

signal action_pressed

const SPRITE_PATH = "res://assets/buttons/enter_key.png"
const FRAME_SIZE = Vector2(128, 128)  # Each frame in 2x2 grid (256x256 total)
const BUTTON_SCALE = 0.75  # Scale down to ~96px for UI

var sprite: TextureRect
var texture: Texture2D
var is_enabled: bool = false
var is_pressed: bool = false
var current_frame: int = 0
var press_tween: Tween

func _ready() -> void:
	var display_size = FRAME_SIZE * BUTTON_SCALE
	custom_minimum_size = display_size
	size = display_size

	# Load the sprite sheet
	texture = load(SPRITE_PATH)

	# Create sprite display
	sprite = TextureRect.new()
	sprite.custom_minimum_size = display_size
	sprite.size = display_size
	sprite.texture = _get_frame_texture(0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.stretch_mode = TextureRect.STRETCH_SCALE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(sprite)

	# Create invisible touch area
	var touch_area = Control.new()
	touch_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_area.mouse_filter = Control.MOUSE_FILTER_STOP
	touch_area.gui_input.connect(_on_gui_input)
	add_child(touch_area)

	set_enabled(false)

func _get_frame_texture(frame: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	# 2x2 grid: frame 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right
	var col = frame % 2
	var row = frame / 2
	atlas.region = Rect2(col * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return atlas

func _on_gui_input(event: InputEvent) -> void:
	if not is_enabled:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_play_press_animation()
		else:
			_play_release_animation()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_play_press_animation()
			else:
				_play_release_animation()

func _play_press_animation() -> void:
	if is_pressed:
		return
	is_pressed = true

	if press_tween:
		press_tween.kill()

	# Animate through frames 0 -> 1 -> 2 -> 3 (pressed)
	press_tween = create_tween()
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(1)).set_delay(0.03)
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(2)).set_delay(0.03)
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(3)).set_delay(0.03)

func _play_release_animation() -> void:
	if not is_pressed:
		return
	is_pressed = false

	if press_tween:
		press_tween.kill()

	# Animate back 3 -> 2 -> 1 -> 0 and emit action
	press_tween = create_tween()
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(2)).set_delay(0.03)
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(1)).set_delay(0.03)
	press_tween.tween_callback(func(): sprite.texture = _get_frame_texture(0)).set_delay(0.03)
	press_tween.tween_callback(func(): action_pressed.emit()).set_delay(0.02)

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	# Dim when disabled
	if enabled:
		sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color(0.4, 0.4, 0.4, 0.5)
