extends Node2D
class_name Weapon

enum WeaponType {MELEE, RANGED}
enum WeaponState {IDLE, WINDUP, ATTACKING, COOLDOWN}

@export var weapon_type: WeaponType
@export var attack_cooldown: float = 1.0

@export var current_state: WeaponState = WeaponState.IDLE

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_state_machine = animation_tree["parameters/playback"]

func _ready():
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", on_attack_timer_timeout)

func update_weapon_rotation(mouse_vector):
	if mouse_vector.x >= 0:
		animation_tree.set("parameters/WeaponRight/blend_position", mouse_vector)
	else:
		animation_tree.set("parameters/WeaponLeft/blend_position", mouse_vector)

func attack(mouse_vector: Vector2):
	match current_state:
		WeaponState.IDLE:
			start_windup(mouse_vector)
		WeaponState.WINDUP:
			if Input.is_action_just_released("CHR_ATTACK"):
				release_attack(mouse_vector)

func start_windup(mouse_vector: Vector2):
	current_state = WeaponState.WINDUP
	if mouse_vector.x >= 0:
		animation_state_machine.travel("WindupRight")
	else:
		animation_state_machine.travel("WindupLeft")
	animation_tree.set("parameters/WindupRight/blend_position", mouse_vector)
	animation_tree.set("parameters/WindupLeft/blend_position", mouse_vector)

func release_attack(mouse_vector: Vector2):
	current_state = WeaponState.ATTACKING
	if mouse_vector.x >= 0:
		animation_state_machine.travel("AttackRight")
	else:
		animation_state_machine.travel("AttackLeft")
	animation_tree.set("parameters/AttackRight/blend_position", mouse_vector)
	animation_tree.set("parameters/AttackLeft/blend_position", mouse_vector)
	attack_timer.start()

func on_attack_timer_timeout():
	current_state = WeaponState.IDLE
