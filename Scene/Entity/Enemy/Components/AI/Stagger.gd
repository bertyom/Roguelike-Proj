extends AI_State

func _physics_process(_delta):
	controlled_body.velocity = Vector2.ZERO
	if controlled_body.facing_right:
		controlled_body.animation_tree.travel("R_Stagger")
		weapon.animation_tree.travel("Right")
	else:
		controlled_body.animation_tree.travel("L_Stagger")
		weapon.animation_tree.travel("Left")
