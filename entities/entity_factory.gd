class_name EntityFactory
extends RefCounted

## Factory to create entities with components

static func create_player(pos: Vector2) -> CharacterBody2D:
	var entity = CharacterBody2D.new()
	entity.name = "Player"
	entity.position = pos
	entity.add_to_group("entity")

	# Add components
	var velocity = VelocityComponent.new()
	velocity.max_speed = 300.0
	velocity.attach(entity)
	entity.set_meta("velocity", velocity)

	var input = InputComponent.new()
	input.attach(entity)
	entity.set_meta("input", input)

	var sprite = SpriteComponent.new()
	sprite.color = Color(0.2, 0.6, 1.0)
	sprite.size = Vector2(50, 50)
	sprite.attach(entity)
	entity.set_meta("sprite", sprite)

	var collision = CollisionComponent.new()
	collision.shape_size = Vector2(50, 50)
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

	# Create visual representation
	var color_rect = ColorRect.new()
	color_rect.color = sprite.color
	color_rect.size = sprite.size
	color_rect.position = -sprite.size / 2
	entity.add_child(color_rect)

	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = collision.shape_size
	collision_shape.shape = rect_shape
	entity.add_child(collision_shape)

	return entity


static func create_wall(pos: Vector2, size: Vector2) -> StaticBody2D:
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

	# Create collision
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = size
	collision_shape.shape = rect_shape
	entity.add_child(collision_shape)

	return entity


static func create_workstation(pos: Vector2, ws_size: Vector2 = Vector2(100, 100)) -> StaticBody2D:
	var entity = StaticBody2D.new()
	entity.name = "Workstation"
	entity.position = pos
	entity.add_to_group("entity")

	# Add workstation component
	var workstation = WorkstationComponent.new()
	workstation.interaction_radius = 100.0
	workstation.attach(entity)
	entity.set_meta("workstation", workstation)

	# Add sprite component
	var sprite = SpriteComponent.new()
	sprite.color = Color(0.55, 0.35, 0.15)  # Brown color
	sprite.size = ws_size
	sprite.attach(entity)
	entity.set_meta("sprite", sprite)

	# Add collision component
	var collision = CollisionComponent.new()
	collision.shape_size = ws_size
	collision.is_static = true
	collision.attach(entity)
	entity.set_meta("collision", collision)

	# Create visual
	var color_rect = ColorRect.new()
	color_rect.color = sprite.color
	color_rect.size = ws_size
	color_rect.position = -ws_size / 2
	entity.add_child(color_rect)

	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = ws_size
	collision_shape.shape = rect_shape
	entity.add_child(collision_shape)

	return entity