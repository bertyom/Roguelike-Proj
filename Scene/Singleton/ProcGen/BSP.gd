extends ProcGenAlgo

var root_node: Branch
var paths: Array = []

#FIXME Creates diagonal paths sometimes, dunno why

func start():
	root_node = Branch.new(Vector2i(0,0), Vector2i(80,80))
	root_node.split(4, paths)
	return generate()

func generate():
	initialize_matrix(80,80)
	add_rooms()
	connect_rooms_with_alternatives()
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
		
		# Store room data
		var room_data = {
			"corners": {
				"top_left": top_left,
				"bottom_right": bottom_right
			},
			"center": Vector2i(
				top_left.x + (bottom_right.x - top_left.x) / 2,
				top_left.y + (bottom_right.y - top_left.y) / 2
			),
			"connected": false
		}
		rooms.append(room_data)
		
		# Fill room in matrix
		for x in range(top_left.x, bottom_right.x + 1):
			for y in range(top_left.y, bottom_right.y + 1):
				set_matrix_cell(x, y, GameMap.proc_gen.FLOOR_ROOM)

# Helper functions for MST
func find_set(parent: Array, x: int) -> int:
	if parent[x] != x:
		parent[x] = find_set(parent, parent[x])
	return parent[x]

func union_sets(parent: Array, x: int, y: int) -> bool:
	var px = find_set(parent, x)
	var py = find_set(parent, y)
	if px != py:
		parent[px] = py
		return true
	return false

func connect_rooms_with_alternatives():
	# Create edges between all rooms
	var edges = []
	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			edges.append({
				"room1": i,
				"room2": j,
				"distance": rooms[i].center.distance_to(rooms[j].center)
			})
	
	# Sort edges by distance
	edges.sort_custom(func(a, b): return a.distance < b.distance)
	
	# Initialize disjoint set for MST
	var parent = []
	for i in range(rooms.size()):
		parent.append(i)
	
	# Build MST using Kruskal's algorithm
	var mst_edges = []
	var additional_edges = []
	var rng = RandomNumberGenerator.new()
	
	for edge in edges:
		if union_sets(parent, edge.room1, edge.room2):
			mst_edges.append(edge)
			if mst_edges.size() == rooms.size() - 1:
				break
	
	# Add additional paths based on certain criteria
	for edge in edges:
		# Skip edges already in MST
		if edge in mst_edges:
			continue
			
		# Only consider relatively short connections
		# Adjust the multiplier (1.5) to control how far apart rooms can be for alternative paths
		var closest_mst_distance = INF
		for mst_edge in mst_edges:
			closest_mst_distance = min(closest_mst_distance, mst_edge.distance)
		
		if edge.distance <= closest_mst_distance * 1.5:
			# Add the edge with a probability (adjust 0.3 to control density of alternative paths)
			if rng.randf() < 0.3:
				additional_edges.append(edge)
	
	# Connect rooms using both MST and additional edges
	for edge in mst_edges + additional_edges:
		var room1 = rooms[edge.room1]
		var room2 = rooms[edge.room2]
		
		# For additional paths, try to use different access points
		if edge in additional_edges:
			place_and_connect_rooms_alternative(room1, room2)
		else:
			place_and_connect_rooms(room1, room2)
		
		room1.connected = true
		room2.connected = true

func place_and_connect_rooms(room1: Dictionary, room2: Dictionary):
	var access1 = get_best_access_point(room1, room2.center)
	var access2 = get_best_access_point(room2, room1.center)
	
	# Get corridor start/end points offset from room edges
	var path_start = get_corridor_point(access1, room1)
	var path_end = get_corridor_point(access2, room2)
	
	# Create the connections
	create_simple_path(access1, path_start)  # Room1 to corridor
	create_simple_path(path_start, path_end)  # Main corridor
	create_simple_path(path_end, access2)  # Corridor to Room2

func place_and_connect_rooms_alternative(room1: Dictionary, room2: Dictionary):
	# Get alternative access points by trying different walls than the primary connection
	var access1 = get_alternative_access_point(room1, room2.center)
	var access2 = get_alternative_access_point(room2, room1.center)
	
	var path_start = get_corridor_point(access1, room1)
	var path_end = get_corridor_point(access2, room2)
	
	create_simple_path(access1, path_start)
	create_simple_path(path_start, path_end)
	create_simple_path(path_end, access2)

func get_best_access_point(room: Dictionary, target_pos: Vector2i) -> Vector2i:
	var dx = target_pos.x - room.center.x
	var dy = target_pos.y - room.center.y
	
	var point = Vector2i()
	
	# Choose the wall closest to the target
	if abs(dx) > abs(dy):
		# Use east or west wall
		point.y = room.center.y
		if dx > 0:
			point.x = room.corners.bottom_right.x + 1  # East wall
		else:
			point.x = room.corners.top_left.x - 1      # West wall
	else:
		# Use north or south wall
		point.x = room.center.x
		if dy > 0:
			point.y = room.corners.bottom_right.y + 1  # South wall
		else:
			point.y = room.corners.top_left.y - 1      # North wall
	
	# Adjust point to be one tile away from corners
	if point.x == room.corners.bottom_right.x + 1 or point.x == room.corners.top_left.x - 1:
		point.y = clamp(point.y, 
			room.corners.top_left.y + 1, 
			room.corners.bottom_right.y - 1)
	else:
		point.x = clamp(point.x, 
			room.corners.top_left.x + 1, 
			room.corners.bottom_right.x - 1)
	
	return point

func get_alternative_access_point(room: Dictionary, target_pos: Vector2i) -> Vector2i:
	var dx = target_pos.x - room.center.x
	var dy = target_pos.y - room.center.y
	var rng = RandomNumberGenerator.new()
	
	var point = Vector2i()
	
	# Choose a wall semi-randomly, with preference for walls NOT closest to target
	if rng.randf() < 0.7:  # 70% chance to choose the non-optimal wall
		if abs(dx) > abs(dy):
			# Original would choose east/west, so we choose north/south
			point.x = room.center.x
			if rng.randf() < 0.5:
				point.y = room.corners.bottom_right.y + 1  # South wall
			else:
				point.y = room.corners.top_left.y - 1      # North wall
		else:
			# Original would choose north/south, so we choose east/west
			point.y = room.center.y
			if rng.randf() < 0.5:
				point.x = room.corners.bottom_right.x + 1  # East wall
			else:
				point.x = room.corners.top_left.x - 1      # West wall
	else:
		# 30% chance to use the original optimal wall selection
		return get_best_access_point(room, target_pos)
	
	# Adjust point to be one tile away from corners
	if point.x == room.corners.bottom_right.x + 1 or point.x == room.corners.top_left.x - 1:
		point.y = clamp(point.y, 
			room.corners.top_left.y + 1, 
			room.corners.bottom_right.y - 1)
	else:
		point.x = clamp(point.x, 
			room.corners.top_left.x + 1, 
			room.corners.bottom_right.x - 1)
	
	return point

func get_corridor_point(access_point: Vector2i, room: Dictionary) -> Vector2i:
	# Determine which wall the access point is on
	var corridor_point = access_point
	
	if access_point.x == room.corners.bottom_right.x + 1:  # East wall
		corridor_point.x += 1
	elif access_point.x == room.corners.top_left.x - 1:    # West wall
		corridor_point.x -= 1
	elif access_point.y == room.corners.bottom_right.y + 1: # South wall
		corridor_point.y += 1
	else:                                                  # North wall
		corridor_point.y -= 1
		
	return corridor_point

func create_simple_path(start: Vector2i, end: Vector2i):
	if start.x == end.x or start.y == end.y:
		create_straight_path(start, end)
	else:
		# Choose corner based on which dimension has the larger difference
		var corner
		if abs(start.x - end.x) > abs(start.y - end.y):
			corner = Vector2i(end.x, start.y)
		else:
			corner = Vector2i(start.x, end.y)
		
		create_straight_path(start, corner)
		create_straight_path(corner, end)

func create_straight_path(start: Vector2i, end: Vector2i):
	var direction = (end - start).sign()
	var current = start
	
	while current != end + direction:
		if matrix[current.x][current.y] != GameMap.proc_gen.FLOOR_ROOM:
			set_matrix_cell(current.x, current.y, GameMap.proc_gen.FLOOR_PATH)
		current += direction
