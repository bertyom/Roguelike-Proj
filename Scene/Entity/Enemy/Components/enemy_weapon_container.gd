extends Node2D

var attack_range: float
var nodesDesired : int = 9
@export var controlled_body: CharacterBody2D
var current_weapon: EnemyWeaponBase
@onready var attack_range_detector: Area2D = $AttackRangeDetector

func setup():
	find_weapon_child()
	update_attack_radius_polygon()

func find_weapon_child():
	for child in get_children():
		if child is EnemyWeaponBase:
			current_weapon = child
			return
	if current_weapon:
		current_weapon.controlled_body = controlled_body

func update_attack_radius_polygon():
	attack_range = ceil(current_weapon.attack_radius)
	
	var a: float = PI / (nodesDesired - 1)  # Angle between each point
	var poly_points := PackedVector2Array()
	# Add the center point
	poly_points.append(Vector2.ZERO)
	# Create the semi-circle points
	for i in range(nodesDesired):
		var angle = i * a
		var x = cos(angle) * attack_range
		var y = sin(angle) * attack_range
		poly_points.append(Vector2(x, y))
	
	attack_range_detector.get_node("CollisionPolygon2D").polygon = poly_points
