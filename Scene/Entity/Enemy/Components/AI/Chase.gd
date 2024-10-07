extends Node

@onready var parent_node = $"../.."
@onready var navigation_agent = $"../../NavigationAgent2D"
@export_enum("Passive", "Agressive", "None") var behaviour_type: String

func start():
	_setup()
	
func _setup():
	await get_tree().physics_frame
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	randomize()

func _physics_process(delta):
	# Update the target location every frame
	navigation_agent.target_position = PlayerData.player_node.global_position
	
	# Calculate the direction towards the next waypoint
	var current_agent_position: Vector2 = parent_node.global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * parent_node.movement_speed
	parent_node.velocity = new_velocity
	# Move towards the waypoint
	if new_velocity.x >= 0:
		parent_node.anim_tree.travel("R_Walk")
	else:
		parent_node.anim_tree.travel("L_Walk")
	
	parent_node.move_and_slide()
