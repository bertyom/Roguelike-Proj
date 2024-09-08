extends Node

const TILE_SIZE = 32  # Hardcoded tile size
const DIR_VECTORS := {
	"MOVE_UP": Vector2i(0, -1),
	"MOVE_DOWN": Vector2i(0, 1),
	"MOVE_LEFT": Vector2i(-1, 0),
	"MOVE_RIGHT": Vector2i(1, 0),
	"MOVE_UP+LEFT": Vector2i(-1, -1),
	"MOVE_UP+RIGHT": Vector2i(1, -1),
	"MOVE_DOWN+LEFT": Vector2i(-1, 1),
	"MOVE_DOWN+RIGHT": Vector2i(1, 1),
	"MOVE_WAIT": Vector2i(0, 0)
}

var current_tilemap_node
var current_player_node
var current_traverse_node
var input_move_actions: Array
var tile_size

func _ready() -> void:
	filter_move_inputs()

func filter_move_inputs():
	#Obtain all actions from InputMap, leave only player movement ones
	input_move_actions = InputMap.get_actions().filter(func(action): return action.begins_with("MOVE_"))
