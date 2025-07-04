extends AI_State

var min_distance = 40
var max_distance = 60
var is_waiting = false
var seeking = true

@onready var wander_timer = Timer.new()

func setup():
	super.setup()
	await get_tree().physics_frame
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	randomize()

	wander_timer.one_shot = true
	add_child(wander_timer)
	wander_timer.timeout.connect(_on_wander_timer_timeout)

	seeking = true
	update_pathfinding(controlled_body.lost_position)

func _physics_process(_delta):
	if seeking:
		if controlled_body.lost_position != null:
			var velocity = move_towards_target()
			if is_navigation_finished():
				seeking = false
				is_waiting = true
				wander_timer.start(randf_range(0.5, 2.5))
			else:
				_update_animation(velocity)
				
	elif !is_waiting:
		if controlled_body.lost_position != null and is_navigation_finished():
			is_waiting = true
			wander_timer.start(randf_range(0.5, 2.5))
		else:
			var velocity = move_towards_target()
			_update_animation(velocity)
	else:
		controlled_body.velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)

func _on_wander_timer_timeout():
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0, 2 * PI)
	var new_position = controlled_body.lost_position + Vector2(random_distance, 5).rotated(random_angle)
	update_pathfinding(new_position)
	is_waiting = false

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
