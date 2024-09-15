extends Node2D

@export var cell_entities: Dictionary
@export var cell_contents: Dictionary


func _ready() -> void:
	GameMap.set_tilemap(self)
	GameMap.current_traverse_node = get_tree().get_first_node_in_group("tile_traverse")

	# Initialize positions of all entities
	var entities = get_tree().get_nodes_in_group("entity")
	for entity in entities:
		if entity is Entity:
			var entity_pos: Vector2i = GameMap.current_traverse_node.local_to_map(entity.position)
			cell_entities[entity_pos] = entity
