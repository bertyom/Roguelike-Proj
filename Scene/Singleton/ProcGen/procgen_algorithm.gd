extends Node2D
class_name ProcGenAlgo

@export var matrix: Array = []
@export var world_size = Vector2i()
@export var rooms: Array = []

func initialize_matrix(size_x: int, size_y: int):
	world_size = Vector2i(size_x, size_y)
	matrix = []
	for x in range(size_x):
		var column = []
		for y in range(size_y):
			column.append(GameMap.proc_gen.EMPTY)
		matrix.append(column)

func add_walls():
	var temp_matrix = matrix.duplicate(true)
	for x in range(world_size.x):
		for y in range(world_size.y):
			if matrix[x][y] == GameMap.proc_gen.FLOOR_ROOM or matrix[x][y] == GameMap.proc_gen.FLOOR_PATH:
				for direction in GameMap.DIR_VECTORS.values():
					var nx = x + direction.x
					var ny = y + direction.y
					if is_valid_position(nx, ny) and matrix[nx][ny] == GameMap.proc_gen.EMPTY:
						temp_matrix[nx][ny] = GameMap.proc_gen.WALL
	matrix = temp_matrix

func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < world_size.x and y >= 0 and y < world_size.y

func set_matrix_cell(x: int, y: int, value: int):
	if is_valid_position(x, y):
		matrix[x][y] = value
