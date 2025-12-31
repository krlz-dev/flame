class_name System
extends Node

## Base class for all ECS systems
## Systems contain logic and process entities with required components

var world: Node = null

func _init(w: Node = null) -> void:
	world = w

## Override to specify which component types this system requires
func get_required_components() -> Array[String]:
	return []

## Check if entity has all required components
func entity_matches(entity: Node) -> bool:
	for comp_name in get_required_components():
		if not entity.has_meta(comp_name):
			return false
	return true

## Get all matching entities from world
func get_entities() -> Array[Node]:
	var entities: Array[Node] = []
	if world:
		for child in world.get_children():
			if child.is_in_group("entity") and entity_matches(child):
				entities.append(child)
	return entities

## Override to process entities
func process_system(_delta: float) -> void:
	pass
