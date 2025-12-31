class_name Component
extends Resource

## Base class for all ECS components
## Components are pure data containers - no logic

var entity: Node = null

func attach(ent: Node) -> void:
	entity = ent
