extends AI_State

func _physics_process(_delta):
	if controlled_body.facing_right:
		controlled_body.animation_tree.travel("R_Idle")
		weapon.animation_tree.travel("Right")
	else:
		controlled_body.animation_tree.travel("L_Idle")
		weapon.animation_tree.travel("Left")
