extends AI_State

var can_attack = true
var currently_swinging = false

func setup():
	super.setup()
	await get_tree().physics_frame
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
		weapon.animation_tree.travel("RightWindup")
	else:
		weapon.animation_tree.travel("LeftWindup")
	weapon.attack_timer.start()
	currently_swinging = true

func _physics_process(_delta):
	var velocity = move_towards_player()
	if can_attack:
		_attack()
	_update_animation(velocity)

func _update_animation(velocity: Vector2):
	if !currently_swinging:
		if velocity.x >= 0:
			controlled_body.animation_tree.travel("R_Walk")
			weapon.animation_tree.travel("Right")
		else:
			controlled_body.animation_tree.travel("L_Walk")
			weapon.animation_tree.travel("Left")
	else:
		if controlled_body.facing_right:
			controlled_body.animation_tree.travel("R_Walk")
		else:
			controlled_body.animation_tree.travel("L_Walk")

func _on_AttackTimer_timeout():
	can_attack = true

func _on_attack_finished():
	currently_swinging = false
