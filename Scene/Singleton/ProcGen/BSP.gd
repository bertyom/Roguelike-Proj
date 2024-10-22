extends ProcGenAlgo

var root_node: Branch
var paths: Array = []

func start():
	root_node = Branch.new(Vector2i(0,0), Vector2i(80,80))
	root_node.split(4, paths)
	return generate()

func generate():
	initialize_matrix(80,80)
	add_rooms()
	connect_rooms_with_simple_paths()
	add_walls()
	return matrix

func add_rooms():
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(
			rng.randi_range(2, 3),
			rng.randi_range(2, 3),
			rng.randi_range(2, 3),
			rng.randi_range(2, 3)
		)
		
		# Calculate room corners
		var top_left = Vector2i(
			leaf.position.x + padding.x,
			leaf.position.y + padding.y
		)
		var bottom_right = Vector2i(
			leaf.position.x + leaf.size.x - padding.z,
			leaf.position.y + leaf.size.y - padding.w
		)
		
		# Store room data efficiently
		var room_data = {
			"corners": {
				"top_left": top_left,
				"bottom_right": bottom_right
			},
			"center": Vector2i(
				top_left.x + (bottom_right.x - top_left.x) / 2,
				top_left.y + (bottom_right.y - top_left.y) / 2
			)
		}
		rooms.append(room_data)
		
		# Fill room in matrix
		for x in range(top_left.x, bottom_right.x + 1):
			for y in range(top_left.y, bottom_right.y + 1):
				set_matrix_cell(x, y, GameMap.proc_gen.FLOOR_ROOM)

func connect_rooms_with_simple_paths():
	# Connect each room to the next one
	for i in range(rooms.size() - 1):
		var current_room = rooms[i]
		var next_room = rooms[i + 1]
		create_simple_path(current_room.center, next_room.center)

func create_simple_path(start: Vector2i, end: Vector2i):
	# First try straight line
	if start.x == end.x or start.y == end.y:
		create_straight_path(start, end)
	else:
		# Create dogleg (L-shaped) path
		var corner = Vector2i(end.x, start.y)  # Could also be (start.x, end.y)
		create_straight_path(start, corner)
		create_straight_path(corner, end)

func create_straight_path(start: Vector2i, end: Vector2i):
	var direction = (end - start).sign()
	var current = start
	
	while current != end + direction:
		if matrix[current.x][current.y] != GameMap.proc_gen.FLOOR_ROOM:
			set_matrix_cell(current.x, current.y, GameMap.proc_gen.FLOOR_PATH)
		current += direction

# Helper function to check if point is inside a room
func is_point_in_room(point: Vector2i) -> bool:
	for room in rooms:
		if (point.x >= room.corners.top_left.x and 
			point.x <= room.corners.bottom_right.x and
			point.y >= room.corners.top_left.y and 
			point.y <= room.corners.bottom_right.y):
			return true
	return false

# Helper function to get room containing point
func get_room_containing_point(point: Vector2i) -> Dictionary:
	for room in rooms:
		if (point.x >= room.corners.top_left.x and 
			point.x <= room.corners.bottom_right.x and
			point.y >= room.corners.top_left.y and 
			point.y <= room.corners.bottom_right.y):
			return room
	return {}
