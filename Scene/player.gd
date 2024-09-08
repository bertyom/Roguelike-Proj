extends CharacterBody2D

@onready var nav_agent := $NavAgent

func _ready() -> void:
	GameMap.current_player_node = self
	
func try_move(move_vector: Vector2i):
	#get the node's current and new position
	var current_pos:Vector2i = GameMap.current_traverse_node.local_to_map(position)
	var new_pos:Vector2i = current_pos + move_vector
	var new_pos_tile = GameMap.current_traverse_node.get_cell_tile_data(new_pos)

	# Check if the new position tile has a valid navigation layer
	if new_pos_tile != null and new_pos_tile.get_navigation_polygon(0):
	# Convert the new position to world coordinates
		var new_world_pos:Vector2i = GameMap.current_traverse_node.map_to_local(new_pos)
		position = new_world_pos
	else:
		print("invalid new position")

#TODO Check if the input action is in the GameMap.input_move_actions and handle player movement accordingly
func _input(event):
	if event is InputEventKey and event.is_pressed():
		for action in GameMap.input_move_actions:
			if event.is_action(action):
				try_move(GameMap.DIR_VECTORS[action])
