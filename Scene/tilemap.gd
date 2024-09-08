extends Node2D


func _ready() -> void:
	GameMap.current_tilemap_node = self
	GameMap.current_traverse_node = get_tree().get_first_node_in_group("tile_traverse")
