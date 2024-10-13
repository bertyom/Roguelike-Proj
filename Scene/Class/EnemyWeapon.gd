extends Node2D
class_name EnemyWeaponBase

@export var controlled_body: CharacterBody2D
@export var attack_radius: float
@onready var animation_tree = $AnimationPlayer/AnimationTree["parameters/playback"]
@onready var attack_timer: Timer = $AttackTimer

signal arrow_shot
signal attack_finished

func _ready():
	calculate_attack_radius()

func calculate_attack_radius():
	var weapon_sprite = get_node("WeaponSprite")
	if weapon_sprite:
		var sprite_size = weapon_sprite.texture.get_size()
		var sprite_position = weapon_sprite.position
		
		# Calculate the distance from the weapon's root to the furthest point of the sprite
		var max_distance = max(
			sprite_position.length() + sprite_size.x / 2,
			sprite_position.length() + sprite_size.y / 2
		)
		
		# Add a small buffer (e.g., 10% of the calculated distance)
		attack_radius = max_distance * 1.25
