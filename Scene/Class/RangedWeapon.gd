extends Weapon
class_name RangedWeapon

@export var projectile_scene: PackedScene
@onready var projectile_start: Node2D = $ProjectileStart

func _init():
	weapon_type = WeaponType.RANGED

func _release_attack(mouse_vector: Vector2):
	super.release_attack(mouse_vector)
	spawn_projectile(mouse_vector)

func spawn_projectile(mouse_vector: Vector2):
	var projectile = projectile_scene.instantiate()
	projectile.global_position = projectile_start.global_position
	projectile.rotation = mouse_vector.angle()
	get_tree().current_scene.add_child(projectile)
