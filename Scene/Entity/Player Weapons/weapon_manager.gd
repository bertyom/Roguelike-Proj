extends Node2D

#var current_weapon: Weapon = null
signal attack_state_changed(is_attacking: bool)

@onready var player: CharacterBody2D = get_parent()
@onready var current_weapon: Weapon = get_child(0) #Debug only

var mouse_vector:= Vector2.ZERO
var is_attacking: set = set_attacking

#TODO Add weapon instancing via inventory
#TODO Move the weapon cooldown timer to prevent spamming inventory unequipping

func _process(_delta):
	update_mouse_vector()
	update_weapon_rotation()

func update_mouse_vector():
	mouse_vector = (get_global_mouse_position() - global_position).normalized()

func update_weapon_rotation():
	if current_weapon:
		current_weapon.update_weapon_rotation(mouse_vector)

func start_attack():
	if current_weapon and current_weapon.current_state == Weapon.WeaponState.IDLE:
		current_weapon.start_windup(mouse_vector)

func end_attack():
	if current_weapon and current_weapon.current_state == Weapon.WeaponState.WINDUP:
		current_weapon.release_attack()

func set_attacking(value: bool):
	if is_attacking != value:
		is_attacking = value
		emit_signal("attack_state_changed", is_attacking)
		#print("Attacking = " + str(is_attacking))

func _on_weapon_windup_started():
	set_attacking(true)

func _on_weapon_attack_ended():
	set_attacking(false)
