extends Node

var min_distance = 40
var max_distance = 60
var current_destination = null
var is_waiting = false
var seeking = true
var direction = Vector2.ZERO
var target = Vector2.ZERO
@onready var wander_timer = $WanderTimer
@onready var parent_node = $"../.."
@onready var navigation_agent = $"../../NavigationAgent2D"
@export_enum("Passive", "Agressive", "None") var behaviour_type: String

func start():  # Add a start method to be called when changing state
	_setup()
	seeking = true
	navigation_agent.target_position = parent_node.lost_position

func _setup():
	await get_tree().physics_frame
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	randomize()
	wander_timer.timeout.connect(_on_wander_timer_timeout)

func _physics_process(delta):
	if seeking: #moving to the last seen location
		if parent_node.lost_position != null: #if the enemy has a last seen location
			var current_agent_position: Vector2 = parent_node.global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()
			var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * parent_node.movement_speed
			parent_node.velocity = new_velocity + parent_node.push_vector
			if navigation_agent.is_navigation_finished(): #if the enemy is close to the last seen location
				seeking = false
				is_waiting = true
				wander_timer.start(randf_range(0.5, 2.5))
			else:
				if new_velocity.x >= 0:
					parent_node.anim_tree.travel("R_Walk")
				else:
					parent_node.anim_tree.travel("L_Walk")
				parent_node.move_and_slide()
	elif !is_waiting: #wandering around
		if parent_node.lost_position != null and navigation_agent.is_navigation_finished():
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
		else:
			var current_agent_position: Vector2 = parent_node.global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()
			var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * parent_node.movement_speed
			parent_node.velocity = new_velocity + parent_node.push_vector
			if new_velocity.x >= 0:
				parent_node.anim_tree.travel("R_Walk")
			else:
				parent_node.anim_tree.travel("L_Walk")
			parent_node.move_and_slide()
	else: #waiting
		if parent_node.facing_right:
			parent_node.anim_tree.travel("R_Idle")
		else:
			parent_node.anim_tree.travel("L_Idle")

func _on_wander_timer_timeout():
	# Choose a new destination
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	navigation_agent.target_position = parent_node.lost_position + Vector2(random_distance, 0).rotated(random_angle)
	# Set the new destination for the navigation agent
	# Resume movement
	is_waiting = false
