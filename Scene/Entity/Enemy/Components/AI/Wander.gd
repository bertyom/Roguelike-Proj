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
		var velocity = move_towards_waypoint(nav_agent.target_position)
		_update_animation(velocity)
		
		if is_navigation_finished():
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
	else:
		controlled_body.velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)

func _choose_new_destination():
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	var new_destination = start_wander_position + Vector2(random_distance, 0).rotated(random_angle)
	update_pathfinding(new_destination)

func _update_animation(velocity: Vector2):
	if velocity == Vector2.ZERO:
		if controlled_body.facing_right:
			controlled_body.animation_tree.travel("R_Idle")
			weapon.animation_tree.travel("Right")
		else:
			controlled_body.animation_tree.travel("L_Idle")
			weapon.animation_tree.travel("Left")
	else:
		if velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Walk")
			weapon.animation_tree.travel("Right")
		else:
			controlled_body.animation_tree.travel("L_Walk")
			weapon.animation_tree.travel("Left")

func _on_wander_timer_timeout():
	_choose_new_destination()
	is_waiting = false
	stuck_timer.start(stuck_timeout)
