extends Node2D

#var current_weapon: Weapon = null

@onready var player: CharacterBody2D = get_parent()
@onready var current_weapon: Weapon = get_child(0) #Debug only

var mouse_vector: Vector2 = Vector2.ZERO


func _process(delta):
	handle_input()
	update_mouse_vector()
	update_weapon_rotation()

func update_mouse_vector():
	mouse_vector = (get_global_mouse_position() - global_position).normalized()

func handle_input():
	if Input.is_action_pressed("WEAPON_ATTACK"):
		start_attack()
	elif Input.is_action_just_released("WEAPON_ATTACK"):
		end_attack()
		
func update_weapon_rotation():
	if current_weapon:
		current_weapon.update_weapon_rotation(mouse_vector)

func start_attack():
	if current_weapon and current_weapon.current_state == Weapon.WeaponState.IDLE:
		current_weapon.start_windup(mouse_vector)

func end_attack():
	if current_weapon and current_weapon.current_state == Weapon.WeaponState.WINDUP:
		current_weapon.release_attack()
