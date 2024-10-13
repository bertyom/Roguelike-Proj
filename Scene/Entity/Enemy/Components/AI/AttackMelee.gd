extends AI_State

var can_attack = true
var currently_swinging = false

func setup():
	nav_agent = controlled_body.navigation_agent
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	randomize()
	if !weapon.attack_timer.timeout.is_connected(_on_AttackTimer_timeout):
		weapon.attack_timer.timeout.connect(_on_AttackTimer_timeout)
	if !weapon.attack_finished.is_connected(_on_attack_finished):
		weapon.attack_finished.connect(_on_attack_finished)

func _attack():
	can_attack = false
	if controlled_body.velocity.x >= 0:
		weapon.anim_state_machine.travel("RightWindup")
	else:
		weapon.anim_state_machine.travel("LeftWindup")
	weapon.attack_timer.start()
	currently_swinging = true

func _physics_process(_delta):
	nav_agent.target_position = PlayerData.player_node.global_position
	
	var current_position: Vector2 = controlled_body.global_position
	var next_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = (next_position - current_position).normalized() * controlled_body.movement_speed
	controlled_body.velocity = new_velocity

	if can_attack:
		_attack()

	_update_animation()
	
	controlled_body.move_and_slide()

func _update_animation():
	if !currently_swinging:
		if controlled_body.velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Walk")
			weapon.animation_tree.travel("Right")
		else:
			controlled_body.animation_tree.travel("L_Walk")
			weapon.animation_tree.travel("Right")
	else:
		if controlled_body.facing_right:
			controlled_body.animation_tree.travel("R_Walk")
		else:
			controlled_body.animation_tree.travel("L_Walk")

func _on_AttackTimer_timeout():
	can_attack = true

func _on_attack_finished():
	currently_swinging = false
