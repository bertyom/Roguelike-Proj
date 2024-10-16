extends Area2D

@export var push_strength: float = 200.0
@export var push_falloff: float = 100.0

func _ready():
	var radius = get_parent().get_node_or_null("WorldCollision").shape.radius
	get_node("CollisionShape2D").shape.radius = radius

func get_push_vector() -> Vector2:
	var push_vector = Vector2.ZERO
	var areas = get_overlapping_areas()
	
	if areas.size() > 0:
		var parent = get_parent()
		if parent:
			for area in areas:
				var collision_point = area.global_position
				var direction = parent.global_position - collision_point
				var distance = direction.length()
				if distance > 0:
					var push_force = (push_strength / distance) * exp(-distance / push_falloff)
					push_vector += direction.normalized() * push_force
	
	return push_vector
