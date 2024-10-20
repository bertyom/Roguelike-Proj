extends AI_State

var starting_position: Vector2
signal returned_to_original

func setup():
	super.setup()
	starting_position = controlled_body.starting_position
	update_pathfinding(starting_position)
	returned_to_original.connect(controlled_body._on_Return)

func _physics_process(_delta):
	if controlled_body.global_position.distance_to(starting_position) < 5:
		emit_signal("returned_to_original")
		return

	var velocity = move_towards_target()
	_update_animation(velocity)

func _update_animation(velocity: Vector2):
	if velocity.x >= 0:
		controlled_body.animation_tree.travel("R_Walk")
	else:
		controlled_body.animation_tree.travel("L_Walk")
