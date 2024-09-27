extends Node

@onready var proc_gen: Node2D = $ProcGen

var current_tilemap_node: Node2D: set = set_tilemap
signal tilemap_loaded

func set_tilemap(new_node: Node2D):
	current_tilemap_node = new_node
	emit_signal("tilemap_loaded")
