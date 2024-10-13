extends AI_State

var min_distance = 30
var max_distance = 50
var is_waiting = false
var start_wander_position: Vector2
var stuck_timer = Timer.new()
var stuck_timeout = 5.0
var wander_timer

func setup():
	nav_agent = controlled_body.navigation_agent
	await get_tree().physics_frame
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	randomize()

	wander_timer = Timer.new()
	wander_timer.one_shot = true
	add_child(wander_timer)
	wander_timer.timeout.connect(_on_wander_timer_timeout)

	add_child(stuck_timer)
	stuck_timer.one_shot = true

	start_wander_position = controlled_body.global_position
	_choose_new_destination()

func _physics_process(_delta):
	if !is_waiting:
		var current_position: Vector2 = controlled_body.global_position
		var next_position: Vector2 = nav_agent.get_next_path_position()

		if nav_agent.is_navigation_finished() or stuck_timer.is_stopped():
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
		else:
			var new_velocity: Vector2 = (next_position - current_position).normalized() * controlled_body.movement_speed
			controlled_body.velocity = new_velocity
			controlled_body.move_and_slide()
			if new_velocity.x >= 0:
				controlled_body.animation_tree.travel("R_Walk")
			else:
				controlled_body.animation_tree.travel("L_Walk")
	else:
		if controlled_body.velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Idle")
		else:
			controlled_body.animation_tree.travel("L_Idle")

func _on_wander_timer_timeout():
	_choose_new_destination()
	is_waiting = false
	stuck_timer.start(stuck_timeout)

func _choose_new_destination():
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	nav_agent.target_position = start_wander_position + Vector2(random_distance, 5).rotated(random_angle)
