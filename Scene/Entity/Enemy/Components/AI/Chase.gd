extends AI_State

func setup():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	randomize()

func _physics_process(_delta):
	# Update the target location every frame
	if nav_agent:
		nav_agent.target_position = PlayerData.player_node.global_position
		
		# Calculate the direction towards the next waypoint
		var current_agent_position: Vector2 = controlled_body.global_position
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * controlled_body.movement_speed
		controlled_body.velocity = new_velocity
		# Move towards the waypoint
		if new_velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Walk")
			weapon.animation_tree.travel("Right")
		else:
			controlled_body.animation_tree.travel("L_Walk")
			weapon.animation_tree.travel("Left")
