extends AI_State

func setup():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 15.0
	randomize()

func _physics_process(_delta):
	var new_velocity = move_towards_player()
	_update_animation(new_velocity)

func _update_animation(velocity: Vector2):
	if velocity.x >= 0:
		controlled_body.animation_tree.travel("R_Walk")
		weapon.animation_tree.travel("Right")
	else:
		controlled_body.animation_tree.travel("L_Walk")
		weapon.animation_tree.travel("Left")
