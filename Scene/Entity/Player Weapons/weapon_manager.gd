extends Node2D

#var current_weapon: Weapon = null
signal attack_state_changed(is_attacking: bool)

@onready var player: CharacterBody2D = get_parent()
@onready var current_weapon: Weapon = get_child(0) #Debug only

var mouse_vector:= Vector2.ZERO
var is_attacking: set = set_attacking


func _process(_delta):
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

func set_attacking(value: bool):
	if is_attacking != value:
		is_attacking = value
		emit_signal("attack_state_changed", is_attacking)
		#print("Attacking = " + str(is_attacking))

func _on_weapon_windup_started():
	set_attacking(true)

func _on_weapon_attack_ended():
	set_attacking(false)
