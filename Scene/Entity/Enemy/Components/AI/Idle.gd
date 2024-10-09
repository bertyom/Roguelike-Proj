extends AI_State

func _physics_process(_delta):
	if controlled_body.facing_right:
		controlled_body.anim_tree.travel("R_Idle")
	else:
		controlled_body.anim_tree.travel("L_Idle")

	controlled_body.velocity = Vector2.ZERO
	controlled_body.move_and_slide()
