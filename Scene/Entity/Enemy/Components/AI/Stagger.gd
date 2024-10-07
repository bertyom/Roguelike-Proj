extends Node
@onready var parent_node = $"../.."
var stopped = false
@export_enum("Passive", "Agressive", "None") var behaviour_type: String
var direction = Vector2.ZERO

func _physics_process(delta):
	parent_node.velocity += parent_node.push_vector
	parent_node.move_and_slide()
	if parent_node.facing_right:
		parent_node.anim_tree.travel("R_Stagger")
	else:
		parent_node.anim_tree.travel("L_Stagger")
