extends Area2D

@export var nodesDesired: int = 9
@export var radius: float = 100.0  # Default radius, can be changed in the inspector

@onready var detection_polygon = $CollisionPolygon2D

func _ready():
	update_polygon()

func update_polygon():
	var a: float = PI / (nodesDesired - 1)  # Angle between each point
	var poly_points := PackedVector2Array()
	
	# Add the center point
	poly_points.append(Vector2.ZERO)
	
	# Create the semi-circle points
	for i in range(nodesDesired):
		var angle = i * a
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		poly_points.append(Vector2(x, y))
	
	detection_polygon.polygon = poly_points

func set_radius(new_radius: float):
	radius = new_radius
	update_polygon()

func set_nodes(new_nodes: int):
	nodesDesired = new_nodes
	update_polygon()
