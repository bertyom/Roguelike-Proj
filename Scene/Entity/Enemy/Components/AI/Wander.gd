extends Node

var min_distance = 30
var max_distance = 50
var current_destination = null
@onready var wander_timer = $WanderTimer
@onready var parent_node = $"../.."
@onready var navigation_agent = $"../../NavigationAgent2D"
@onready var target_position = null
var start_wander_position: Vector2
@export_enum("Passive", "Agressive", "None") var behaviour_type: String
var stuck_timer = Timer.new()
var stuck_timeout = 5.0
var current_agent_position: Vector2
var is_waiting = false

func start():
	_setup()
	start_wander_position = parent_node.global_position
	
func _setup():
	await get_tree().physics_frame
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	randomize()

	wander_timer.timeout.connect(_on_wander_timer_timeout)
	add_child(stuck_timer)

func _physics_process(delta):
	if !is_waiting:
		current_agent_position = parent_node.global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		if navigation_agent.is_navigation_finished() or stuck_timer.is_stopped():
			# Pause movement and wait for a bit
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
		else:
			# Move towards the current destination
			var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * parent_node.movement_speed
			parent_node.velocity = new_velocity

			if new_velocity.x >= 0:
				parent_node.anim_tree.travel("R_Walk")
			else:
				parent_node.anim_tree.travel("L_Walk")
			parent_node.move_and_slide()
	else:
		# We're waiting, so no movement
		if parent_node.facing_right:
			parent_node.anim_tree.travel("R_Idle")
		else:
			parent_node.anim_tree.travel("L_Idle")

func _on_wander_timer_timeout():
	# Choose a new destination
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	navigation_agent.target_position = start_wander_position + Vector2(random_distance, 0).rotated(random_angle)
	# Set the new destination for the navigation agent
	# Resume movement
	is_waiting = false
	stuck_timer.start(stuck_timeout)
