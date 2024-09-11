extends Entity


func _ready() -> void:
	GameMap.current_player_node = self

func try_move(move_vector: Vector2i):
	# Get the node's current and new position
	var current_pos:Vector2i = GameMap.current_traverse_node.local_to_map(position)
	var new_pos:Vector2i = current_pos + move_vector
	
	# Check if the new position tile has a valid navigation layer
	var new_pos_tile = GameMap.current_traverse_node.get_cell_tile_data(new_pos)
	if new_pos_tile != null and new_pos_tile.get_navigation_polygon(0):
	
	# Check if the new position tile is occupied by another entity
		if GameMap.current_tilemap_node.cell_entities.has(new_pos):
	# Attack the entity
			var target_entity = GameMap.current_tilemap_node.cell_entities[new_pos]
			if target_entity is Entity:
				try_attack(target_entity)
	# Move the entity to the new tile's position
		else:
			var new_world_pos:Vector2i = GameMap.current_traverse_node.map_to_local(new_pos)
			handoff_to_cell(current_pos, new_pos)
			position = new_world_pos
	else:
		print("Invalid cell position")


func try_attack(target: Entity):
	var damage = calc_dmg(DMG)
	target.take_damage(damage)


func handoff_to_cell(old_pos: Vector2i, new_pos: Vector2i):
	# Remove self from the old tile's data array
	if GameMap.current_tilemap_node.cell_entities.has(old_pos):
		GameMap.current_tilemap_node.cell_entities.erase(old_pos)

	# Add self to the new tile's data array
	if not GameMap.current_tilemap_node.cell_entities.has(new_pos):
		GameMap.current_tilemap_node.cell_entities[new_pos] = self

func _input(event):
	if event is InputEventKey and event.is_pressed():
		for action in GameMap.input_move_actions:
			if event.is_action(action):
				try_move(GameMap.DIR_VECTORS[action])
