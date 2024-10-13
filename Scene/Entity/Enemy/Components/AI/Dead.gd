extends AI_State

var stopped = false

func _physics_process(_delta):
	if not stopped:
		controlled_body.velocity = Vector2.ZERO
		controlled_body.move_and_slide()
		stopped = true
	
	if controlled_body.facing_right:
		controlled_body.animation_tree.travel("R_Death")
		weapon.animation_tree.travel("Right")
	else:
		controlled_body.animation_tree.travel("L_Death")
		weapon.animation_tree.travel("Left")
