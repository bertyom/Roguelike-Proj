extends Node2D

@export var current_generation_type: GENERATION_TYPE
enum GENERATION_TYPE {BSP}

func _on_game_map_tilemap_loaded() -> void:
	match current_generation_type:
		0: #BSP
			var generator = get_child(current_generation_type)
			print(generator)
			generator.tilemap = GameMap.current_tilemap_node
			generator.start()
