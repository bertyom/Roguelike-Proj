extends Node2D

@export_enum("BSP", "Walker") var current_generation_type: String
var tilemap: TileMapLayer

const EMPTY = 0
const FLOOR = 1
const WALL = 2

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
				FLOOR:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))
				WALL:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
