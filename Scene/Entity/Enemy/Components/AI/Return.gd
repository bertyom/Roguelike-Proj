extends Node

var direction
var target
@onready var parent_node = $"../.."
@onready var nav_agent = $"../../NavigationAgent2D"
@export_enum("Passive", "Agressive", "None") var behaviour_type: String
signal returned_to_original

func start():
	_setup()
	
func _setup():
	nav_agent.set_target_location(parent_node.starting_position)
	returned_to_original.connect(parent_node._on_Return)

func _physics_process(delta):
	# If we've reached the starting position, go to the Idle state
	if (parent_node.global_position - parent_node.starting_position).length() < 5:
		emit_signal("returned_to_original")
		return

	# Otherwise, move towards the starting position
	target = parent_node.global_position.direction_to(nav_agent.get_next_location())
	direction = target + parent_node.push_vector
	if target.x >= 0:
		parent_node.anim_tree.travel("R_Walk")
	else:
		parent_node.anim_tree.travel("L_Walk")
		
	parent_node.move_and_slide(direction * parent_node.movement_speed)
