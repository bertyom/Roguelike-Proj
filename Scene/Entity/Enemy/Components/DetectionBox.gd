extends Area2D

var nodesDesired : int = 9
@export var radius: float
@onready var parent_node = $".."

func _ready():
	var a : float = PI / float(nodesDesired - 1) # 1.0 for half circle
	var poly_points := PackedVector2Array() # The array of points for the Polygon2D
	for i in range(nodesDesired):
		var x = sin(i * a) * radius
		var y = cos(i * a) * radius
		poly_points.append(Vector2(x, y))
	var polygon = get_node("CollisionPolygon2D")
	polygon.polygon = poly_points
