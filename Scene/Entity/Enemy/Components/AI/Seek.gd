extends AI_State

var min_distance = 40
var max_distance = 60
var is_waiting = false
var seeking = true

@onready var wander_timer = Timer.new()

func setup():
	nav_agent = controlled_body.navigation_agent
	await get_tree().physics_frame
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	randomize()

	wander_timer.one_shot = true
	add_child(wander_timer)
	wander_timer.timeout.connect(_on_wander_timer_timeout)

	seeking = true
	nav_agent.target_position = controlled_body.lost_position

func _physics_process(delta):
	if seeking:
		if controlled_body.lost_position != null:
			var current_position: Vector2 = controlled_body.global_position
			var next_position: Vector2 = nav_agent.get_next_path_position()
			var new_velocity: Vector2 = (next_position - current_position).normalized() * controlled_body.movement_speed
			controlled_body.velocity = new_velocity + controlled_body.push_vector
			if nav_agent.is_navigation_finished():
				seeking = false
				is_waiting = true
				wander_timer.start(randf_range(0.5, 2.5))
			else:
				_update_animation(new_velocity)
				controlled_body.move_and_slide()
	elif !is_waiting:
		if controlled_body.lost_position != null and nav_agent.is_navigation_finished():
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
		else:
			var current_position: Vector2 = controlled_body.global_position
			var next_position: Vector2 = nav_agent.get_next_path_position()
			var new_velocity: Vector2 = (next_position - current_position).normalized() * controlled_body.movement_speed
			controlled_body.velocity = new_velocity + controlled_body.push_vector
			_update_animation(new_velocity)
			controlled_body.move_and_slide()
	else:
		_update_animation(Vector2.ZERO)

func _on_wander_timer_timeout():
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	nav_agent.target_position = controlled_body.lost_position + Vector2(random_distance, 5).rotated(random_angle)
	is_waiting = false

func _update_animation(velocity: Vector2):
	if velocity == Vector2.ZERO:
		if controlled_body.facing_right:
			controlled_body.animation_tree.travel("R_Idle")
		else:
			controlled_body.animation_tree.travel("L_Idle")
	else:
		if velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Walk")
		else:
			controlled_body.animation_tree.travel("L_Walk")
