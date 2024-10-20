extends Area2D
class_name SoftCollision

@export var push_strength: float = 25.0
@export var max_push_distance: float = 5.0
var parent: CharacterBody2D

func _ready():
	parent = get_parent()
	var radius = parent.get_node_or_null("WorldCollision").shape.radius
	if radius:
		get_node("CollisionShape2D").shape.radius = radius

func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	
	if areas.size() > 0:
		for area in areas:
			if area is SoftCollision and area.parent != parent:
				var direction = area.global_position.direction_to(global_position)
				push_vector += direction.normalized()
		
		push_vector = push_vector / areas.size()
		
		# Add a small constant vector to prevent perfect balancing
		push_vector += Vector2(0.1, 0.1)
		
		# Apply push strength
		push_vector *= push_strength
	
	return push_vector
