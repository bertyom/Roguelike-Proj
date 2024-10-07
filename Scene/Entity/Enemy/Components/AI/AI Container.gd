extends Node

@onready var parent_node = $".."

func _ready():
	for child in get_children():
		if child.name != parent_node.active_state:
			child.set_physics_process(false)
