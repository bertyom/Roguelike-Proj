extends Weapon
class_name MeleeWeapon

@onready var hitbox: Area2D = $PlayerWeaponHitbox
@export var base_damage: int
@export var base_knockback: int
@export var weapon_lookup_id: String

func _init():
	weapon_type = WeaponType.MELEE

func _ready():
	super._ready()
	weapon_lookup_id = DatabaseManager.get_weapon_id_by_name(self.name)
	base_damage = DatabaseManager.item_cache[weapon_lookup_id]["Attack"]
	base_knockback = DatabaseManager.item_cache[weapon_lookup_id]["Knockback"]
	
	hitbox.set_meta("Attack", base_damage)
	hitbox.set_meta("Knockback", base_knockback)
