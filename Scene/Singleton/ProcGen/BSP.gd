extends Node2D

var root_node: Branch
var world_size = Vector2i(80, 80)
var paths: Array = []
@export var matrix: Array = []
var tilemap

const EMPTY = 0
const FLOOR = 1
const WALL = 2

func start():
	var rng = RandomNumberGenerator.new()
	root_node = Branch.new(Vector2i(0,0), world_size)
	root_node.split(4, paths)
	return generate()

func generate():
	initialize_matrix()
	add_rooms()
	add_paths()
	add_walls()
	return matrix

func initialize_matrix():
	matrix = []
	for x in range(world_size.x):
		var column = []
		for y in range(world_size.y):
			column.append(EMPTY)
		matrix.append(column)

func add_rooms():
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3))
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x,y, leaf, padding):
					set_matrix_cell(x + leaf.position.x, y + leaf.position.y, FLOOR)

func add_paths():
	for path in paths:
		if path['left'].y == path['right'].y:
			for i in range(path['right'].x - path['left'].x):
				set_matrix_cell(path['left'].x + i, path['left'].y, FLOOR)
		else:
			for i in range(path['right'].y - path['left'].y):
				set_matrix_cell(path['left'].x, path['left'].y + i, FLOOR)

func add_walls():
	var temp_matrix = matrix.duplicate(true)
	for x in range(world_size.x):
		for y in range(world_size.y):
			if matrix[x][y] == FLOOR:
				for direction in GameMap.DIR_VECTORS.values():
					var nx = x + direction.x
					var ny = y + direction.y
					if is_valid_position(nx, ny) and matrix[nx][ny] == EMPTY:
						temp_matrix[nx][ny] = WALL
	matrix = temp_matrix

func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < world_size.x and y >= 0 and y < world_size.y

func set_matrix_cell(x: int, y: int, value: int):
	if is_valid_position(x, y):
		matrix[x][y] = value

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w
