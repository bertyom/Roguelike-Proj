extends Node
@onready var parent_node = $"../.."
var stopped = false
@export_enum("Passive", "Agressive", "None") var behaviour_type: String
var direction

func _physics_process(delta):
	direction += parent_node.push_vector
	parent_node.move_and_slide(direction)
	if parent_node.facing_right:
		parent_node.anim_tree.travel("R_Idle")
	else:
		parent_node.anim_tree.travel("L_Idle")
