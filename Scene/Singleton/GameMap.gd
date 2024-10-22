extends Node

@onready var proc_gen: Node2D = $ProcGen

var current_tilemap_node: Node2D: set = set_tilemap
var current_traverse_node: Node2D
signal tilemap_loaded

const DIR_ORTH = {
	"UP": Vector2i(0, -1),
	"RIGHT": Vector2i(1, 0),
	"DOWN": Vector2i(0, 1),
	"LEFT": Vector2i(-1, 0)
}

const DIR_ALL = {
	"UP": Vector2i(0, -1),
	"UP_RIGHT": Vector2i(1, -1),
	"RIGHT": Vector2i(1, 0),
	"DOWN_RIGHT": Vector2i(1, 1),
	"DOWN": Vector2i(0, 1),
	"DOWN_LEFT": Vector2i(-1, 1),
	"LEFT": Vector2i(-1, 0),
	"UP_LEFT": Vector2i(-1, -1)
}


func set_tilemap(new_node: Node2D):
	current_tilemap_node = new_node
	emit_signal("tilemap_loaded")
