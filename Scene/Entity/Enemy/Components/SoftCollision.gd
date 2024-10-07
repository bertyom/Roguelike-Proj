extends Area2D

func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO

	if areas.size() > 0:
		for area in areas:
			var current_push_vector = area.global_position.direction_to(global_position)
			push_vector += current_push_vector.normalized()
		push_vector = (push_vector/areas.size())+Vector2(0.1,0)
	return push_vector
