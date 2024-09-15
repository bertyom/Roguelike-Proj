extends Entity


func _ready() -> void:
	GameMap.current_player_node = self
	ensure_valid_spawn_position()

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
			if target_entity is Entity and target_entity != self:
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
		#iterate over 8 directions of the movement
		for action in GameMap.input_move_actions:
			if event.is_action(action):
				try_move(GameMap.DIR_VECTORS[action])

#DEBUG Delete afterwards
func ensure_valid_spawn_position():
	var current_pos = GameMap.current_traverse_node.local_to_map(position)
	if not is_valid_position(current_pos):
		var new_pos = find_nearest_valid_position(current_pos)
		if new_pos:
			position = GameMap.current_traverse_node.map_to_local(new_pos)
			handoff_to_cell(current_pos, new_pos)
		else:
			print("Error: No valid spawn position found for player")

func is_valid_position(pos: Vector2i) -> bool:
	var tile_data = GameMap.current_traverse_node.get_cell_tile_data(pos)
	return tile_data != null and tile_data.get_navigation_polygon(0) and not GameMap.current_tilemap_node.cell_entities.has(pos)

func find_nearest_valid_position(start_pos: Vector2i) -> Vector2i:
	var checked_positions = {}
	var to_check = [start_pos]
	
	while not to_check.is_empty():
		var current = to_check.pop_front()
		if is_valid_position(current):
			return current
		
		for direction in GameMap.DIR_VECTORS.values():
			var next_pos = current + direction
			if not checked_positions.has(next_pos):
				checked_positions[next_pos] = true
				to_check.append(next_pos)
	
	return Vector2i.ZERO  # Return ZERO if no valid position is found
