extends ProcGenAlgo

var root_node: Branch
var paths: Array = []
var astar: AStar2D


func start():
	var rng = RandomNumberGenerator.new()
	root_node = Branch.new(Vector2i(0,0), Vector2i(80,80))
	root_node.split(4, paths)
	return generate()

func generate():
	initialize_matrix(80,80) #inherited from ProcGenAlgo
	add_rooms()
	create_astar_graph()
	add_paths()
	add_walls() #inherited from ProcGenAlgo
	return matrix

func add_rooms():
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(rng.randi_range(2, 3), rng.randi_range(2, 3), rng.randi_range(2, 3), rng.randi_range(2, 3))
		var room = {
			"position": Vector2i(leaf.position.x + padding.x, leaf.position.y + padding.y),
			"size": Vector2i(leaf.size.x - padding.x - padding.z, leaf.size.y - padding.y - padding.w)
		}
		rooms.append(room)
		for x in range(room.size.x):
			for y in range(room.size.y):
				set_matrix_cell(room.position.x + x, room.position.y + y, GameMap.proc_gen.FLOOR_ROOM)

func add_paths():
	var room_centers = []
	for room in rooms:
		room_centers.append(Vector2(room.position.x + room.size.x / 2, room.position.y + room.size.y / 2))
	
	var mst = get_minimum_spanning_tree(room_centers)
	for edge in mst:
		var start = room_centers[edge[0]]
		var end = room_centers[edge[1]]
		var path = astar.get_point_path(astar.get_closest_point(start), astar.get_closest_point(end))
		for point in path:
			if matrix[point.x][point.y] != GameMap.proc_gen.FLOOR_ROOM:
				set_matrix_cell(int(point.x), int(point.y), GameMap.proc_gen.FLOOR_PATH)

#FIXME Keep it simple, stupid. Write your own orthogonal connection algo
func create_astar_graph():
	astar = AStar2D.new()
	for x in range(world_size.x):
		for y in range(world_size.y):
			if matrix[x][y] == GameMap.proc_gen.FLOOR_ROOM or matrix[x][y] == GameMap.proc_gen.EMPTY:
				var point_id = astar.get_available_point_id()
				astar.add_point(point_id, Vector2(x, y))
				
				# Connect to left and top neighbors
				for dx in [-1, 0]:
					for dy in [-1, 0]:
						if dx == 0 and dy == 0:
							continue
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and ny >= 0 and (matrix[nx][ny] == GameMap.proc_gen.FLOOR_ROOM or matrix[nx][ny] == GameMap.proc_gen.EMPTY):
							var neighbor_id = astar.get_closest_point(Vector2(nx, ny))
							if not astar.are_points_connected(point_id, neighbor_id):
								astar.connect_points(point_id, neighbor_id)

func get_minimum_spanning_tree(points):
	var edges = []
	for i in range(points.size()):
		for j in range(i + 1, points.size()):
			var dist = points[i].distance_to(points[j])
			edges.append([i, j, dist])
	
	edges.sort_custom(func(a, b): return a[2] < b[2])
	
	var mst = []
	var disjoint_set = DisjointSet.new(points.size())
	
	for edge in edges:
		if disjoint_set.find(edge[0]) != disjoint_set.find(edge[1]):
			mst.append(edge)
			disjoint_set.union(edge[0], edge[1])
	#print(mst)
	return mst
	

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

class DisjointSet:
	var parent: Array

	func _init(size: int):
		parent = []
		for i in range(size):
			parent.append(i)

	func find(x: int) -> int:
		if parent[x] != x:
			parent[x] = find(parent[x])
		return parent[x]

	func union(x: int, y: int):
		var root_x = find(x)
		var root_y = find(y)
		if root_x != root_y:
			parent[root_y] = root_x
