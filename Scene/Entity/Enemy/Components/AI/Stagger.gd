extends AI_State

func _physics_process(_delta):
	#controlled_body.velocity += controlled_body.push_vector
	controlled_body.move_and_slide()
	
	if controlled_body.facing_right:
		controlled_body.animation_tree.travel("R_Stagger")
	else:
		controlled_body.animation_tree.travel("L_Stagger")
