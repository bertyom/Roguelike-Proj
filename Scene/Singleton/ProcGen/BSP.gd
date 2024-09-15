extends Node2D

var root_node: Branch
var world_size = Vector2i(70,70)
var paths: Array = []
var tilemap

func generate():
	add_rooms()
	add_paths()
	add_walls()
	
func start():
	tilemap = tilemap.get_node("Floor")
	tilemap.clear()
	root_node = Branch.new(Vector2i(0,0), world_size)
	root_node.split(4, paths)
	generate()

func add_rooms():
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3))
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x,y, leaf, padding):
					tilemap.set_cell(Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(0, 1))

func add_paths():
	for path in paths:
		if path['left'].y == path['right'].y:
			for i in range(path['right'].x - path['left'].x):
				tilemap.set_cell(Vector2i(path['left'].x+i,path['left'].y), 0, Vector2i(0, 1))
		else:
			for i in range(path['right'].y - path['left'].y):
				tilemap.set_cell(Vector2i(path['left'].x,path['left'].y+i), 0, Vector2i(0, 1))

func add_walls():
	var floor_cells = tilemap.get_used_cells_by_id(0, Vector2i(0, 1))
	var wall_cells = []
	
	for floor_cell in floor_cells:
		for direction in GameMap.DIR_VECTORS.values():
			var neighbor = floor_cell + direction
			if neighbor not in floor_cells and neighbor not in wall_cells:
				wall_cells.append(neighbor)
	
	for wall_cell in wall_cells:
		tilemap.set_cell(wall_cell, 0, Vector2i(0, 0))

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w
