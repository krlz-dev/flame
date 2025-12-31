class_name InteractionSystem
extends System

## Detects when player is near workstations

signal player_near_workstation(workstation: Node, is_near: bool)

var player: Node = null

func set_player(p: Node) -> void:
	player = p

func get_required_components() -> Array[String]:
	return ["workstation"]

func process_system(_delta: float) -> void:
	if not player:
		return

	for entity in get_entities():
		var workstation_comp: WorkstationComponent = entity.get_meta("workstation")
		var distance = player.position.distance_to(entity.position)
		var was_nearby = workstation_comp.is_player_nearby
		workstation_comp.is_player_nearby = distance <= workstation_comp.interaction_radius

		# Emit signal when state changes
		if was_nearby != workstation_comp.is_player_nearby:
			player_near_workstation.emit(entity, workstation_comp.is_player_nearby)

func get_nearby_workstation() -> Node:
	for entity in get_entities():
		var workstation_comp: WorkstationComponent = entity.get_meta("workstation")
		if workstation_comp.is_player_nearby:
			return entity
	return null
