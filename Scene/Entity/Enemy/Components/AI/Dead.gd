extends Node
@onready var parent_node = $"../.."
var stopped = false
var weapon
@export_enum("Passive", "Agressive", "None") var behaviour_type: String

func _physics_process(delta):
	if not stopped:
		parent_node.velocity = Vector2.ZERO
		parent_node.move_and_slide
		stopped = true
	if parent_node.facing_right:
		parent_node.anim_tree.travel("R_Death")
	else:
		parent_node.anim_tree.travel("L_Death")
