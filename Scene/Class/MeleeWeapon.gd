extends Weapon
class_name MeleeWeapon

func _init():
	weapon_type = WeaponType.MELEE

func _release_attack(mouse_vector: Vector2):
	super.release_attack()
	#perform_melee_attack()

func perform_melee_attack():
	#In case I need melee-specific logic in future
	pass
