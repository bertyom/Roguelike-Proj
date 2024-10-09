extends AI_State

signal returned_to_original

func setup():
	nav_agent.set_target_location(controlled_body.starting_position)
	returned_to_original.connect(controlled_body._on_Return)

func _physics_process(delta):
	# If we've reached the starting position, go to the Idle state
	if (controlled_body.global_position - controlled_body.starting_position).length() < 5:
		returned_to_original.emit()
		return

	# Otherwise, move towards the starting position
	var next_location = nav_agent.get_next_location()
	var direction = controlled_body.global_position.direction_to(next_location)
	var new_velocity = (direction + controlled_body.push_vector) * controlled_body.movement_speed
	
	controlled_body.velocity = new_velocity
	
	if direction.x >= 0:
		controlled_body.animation_tree.travel("R_Walk")
	else:
		controlled_body.animation_tree.travel("L_Walk")
	
	controlled_body.move_and_slide()
