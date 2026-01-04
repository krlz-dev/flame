class_name EntityFactory
extends RefCounted

## Factory to create entities with components

const CHARACTER_PATH = "res://assets/character/"
const DIRECTIONS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]
const WALK_FRAMES = 8
const ANIMATION_FPS = 10.0

static func create_player(pos: Vector2) -> CharacterBody2D:
	var entity = CharacterBody2D.new()
	entity.name = "Player"
	entity.position = pos
	entity.add_to_group("entity")

	# Add components
	var velocity = VelocityComponent.new()
	velocity.max_speed = 200.0
	velocity.attach(entity)
	entity.set_meta("velocity", velocity)

	var input = InputComponent.new()
	input.attach(entity)
	entity.set_meta("input", input)

	var collision = CollisionComponent.new()
	collision.shape_size = Vector2(30, 30)
	collision.attach(entity)
	entity.set_meta("collision", collision)

	# Add money component
	var money = MoneyComponent.new()
	money.attach(entity)
	entity.set_meta("money", money)

	# Add work component
	var work = WorkComponent.new()
	work.attach(entity)
	entity.set_meta("work", work)

	# Add animation state component
	var anim_state = AnimationStateComponent.new()
	anim_state.attach(entity)
	entity.set_meta("animation_state", anim_state)

	# Create AnimatedSprite2D with SpriteFrames
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	animated_sprite.sprite_frames = _create_sprite_frames()
	animated_sprite.scale = Vector2(2.3, 2.3)  # Taller character
	animated_sprite.offset = Vector2(0, -24)  # Offset so feet align with position
	animated_sprite.play("idle_south")
	entity.add_child(animated_sprite)

	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(40, 20)  # Wider, shorter for top-down
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(0, 10)  # At feet level
	entity.add_child(collision_shape)

	return entity


static func _create_sprite_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()

	# Remove default animation
	if frames.has_animation("default"):
		frames.remove_animation("default")

	# Create idle animations (using rotation images) for all 8 directions
	for dir in DIRECTIONS:
		var anim_name = "idle_" + dir
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, true)
		frames.set_animation_speed(anim_name, 1.0)

		var texture = _load_texture(CHARACTER_PATH + "rotations/" + dir + ".png")
		if texture:
			frames.add_frame(anim_name, texture)

	# Create walk animations for all 8 directions
	for dir in DIRECTIONS:
		var anim_name = "walk_" + dir
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, true)
		frames.set_animation_speed(anim_name, ANIMATION_FPS)

		for i in range(WALK_FRAMES):
			var frame_path = CHARACTER_PATH + "animations/walking-8-frames/" + dir + "/frame_%03d.png" % i
			var texture = _load_texture(frame_path)
			if texture:
				frames.add_frame(anim_name, texture)

	return frames


static func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null


static func create_wall(pos: Vector2, size: Vector2, collision_offset: Vector2 = Vector2.ZERO) -> StaticBody2D:
	var entity = StaticBody2D.new()
	entity.name = "Wall"
	entity.position = pos
	entity.add_to_group("entity")

	# Add components
	var sprite = SpriteComponent.new()
	sprite.color = Color(0.4, 0.4, 0.4)
	sprite.size = size
	sprite.attach(entity)
	entity.set_meta("sprite", sprite)

	var collision = CollisionComponent.new()
	collision.shape_size = size
	collision.is_static = true
	collision.attach(entity)
	entity.set_meta("collision", collision)

	# Create visual
	var color_rect = ColorRect.new()
	color_rect.color = sprite.color
	color_rect.size = size
	color_rect.position = -size / 2
	entity.add_child(color_rect)

	# Create collision with optional offset for player feet collision
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(size.x, size.y + 40)
	collision_shape.shape = rect_shape
	collision_shape.position = collision_offset
	entity.add_child(collision_shape)

	return entity


static func create_workstation(pos: Vector2, ws_size: Vector2 = Vector2(96, 96)) -> StaticBody2D:
	var entity = StaticBody2D.new()
	entity.name = "Workstation"
	entity.position = pos
	entity.add_to_group("entity")

	# Add workstation component
	var workstation = WorkstationComponent.new()
	workstation.interaction_radius = 20.0  # Must be close to PC to interact
	workstation.interaction_offset = Vector2(0, 50)  # Interaction point in front of desk
	workstation.attach(entity)
	entity.set_meta("workstation", workstation)

	# Add collision component
	var collision = CollisionComponent.new()
	collision.shape_size = Vector2(80, 60)
	collision.is_static = true
	collision.attach(entity)
	entity.set_meta("collision", collision)

	# Create visual using new hacker PC desk sprite
	var desk_sprite = Sprite2D.new()
	var texture = _load_texture("res://assets/props/pc_desk.png")
	if texture:
		desk_sprite.texture = texture
	desk_sprite.scale = Vector2(1.8, 1.8)  # Scale up desk
	desk_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # Pixel art crisp
	entity.add_child(desk_sprite)

	# Collision extends from center to front edge
	# Character stops when feet Y = desk Y (looks like standing at desk)
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(100, 65)  # Extended to catch feet
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(0, 25)  # Shifted down a bit more
	entity.add_child(collision_shape)

	return entity


static func create_prop(pos: Vector2, texture_path: String, scale_factor: float = 1.5, has_collision: bool = false, collision_size: Vector2 = Vector2(50, 30)) -> Node2D:
	var entity: Node2D

	if has_collision:
		entity = StaticBody2D.new()
		var collision_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = collision_size
		collision_shape.shape = rect_shape
		collision_shape.position = Vector2(0, collision_size.y / 4)
		entity.add_child(collision_shape)
	else:
		entity = Node2D.new()

	entity.name = "Prop"
	entity.position = pos

	var sprite = Sprite2D.new()
	var texture = _load_texture(texture_path)
	if texture:
		sprite.texture = texture
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entity.add_child(sprite)

	return entity


static func create_old_car(pos: Vector2) -> StaticBody2D:
	var entity = StaticBody2D.new()
	entity.name = "OldCar"
	entity.position = pos

	var sprite = Sprite2D.new()
	var texture = _load_texture("res://assets/props/old_car.png")
	if texture:
		sprite.texture = texture
	sprite.scale = Vector2(2.0, 2.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entity.add_child(sprite)

	# Large collision for the car
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(200, 100)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(0, 20)
	entity.add_child(collision_shape)

	return entity


static func create_shelving(pos: Vector2) -> StaticBody2D:
	var entity = StaticBody2D.new()
	entity.name = "Shelving"
	entity.position = pos

	var sprite = Sprite2D.new()
	var texture = _load_texture("res://assets/props/shelving.png")
	if texture:
		sprite.texture = texture
	sprite.scale = Vector2(1.8, 1.8)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entity.add_child(sprite)

	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(120, 100)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(0, 10)
	entity.add_child(collision_shape)

	return entity


static func create_cables(pos: Vector2) -> Node2D:
	# Cables are decorative, no collision
	var entity = Node2D.new()
	entity.name = "Cables"
	entity.position = pos

	var sprite = Sprite2D.new()
	var texture = _load_texture("res://assets/props/cables.png")
	if texture:
		sprite.texture = texture
	sprite.scale = Vector2(1.5, 1.5)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entity.add_child(sprite)

	return entity
