extends Node2D

@export_enum("BSP", "Walker") var current_generation_type: String
var tilemap: TileMapLayer

const EMPTY = 0
const FLOOR_ROOM = 1
const FLOOR_PATH = 2
const WALL = 3

func _on_game_map_tilemap_loaded() -> void:
	tilemap = GameMap.current_tilemap_node.get_node("Floor")
	tilemap.clear()
	var generator = get_node(current_generation_type)
	print(generator)
	var matrix = generator.start()
	apply_matrix_to_tilemap(matrix)

func apply_matrix_to_tilemap(matrix: Array) -> void:
	for x in range(len(matrix)):
		for y in range(len(matrix[x])):
			match matrix[x][y]:
				FLOOR_ROOM:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))
				FLOOR_PATH:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
				WALL:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
