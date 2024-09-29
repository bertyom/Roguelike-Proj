extends Node2D
class_name Weapon

enum WeaponType {MELEE, RANGED}
enum WeaponState {IDLE, WINDUP, ATTACKING, COOLDOWN}

@export var weapon_type: WeaponType
@export var attack_cooldown: float = 1.0

#Windup, Attacking and Cooldown are switched in the animation player
@export var current_state: WeaponState = WeaponState.IDLE

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_state_machine = animation_tree["parameters/playback"]

var last_direction: String


func _ready():
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", on_attack_timer_timeout)

func update_weapon_rotation(mouse_vector: Vector2):
	var new_direction = "Right" if mouse_vector.x >= 0 else "Left"
	
	# Update blend position for all states
	animation_tree.set("parameters/WeaponRight/blend_position", mouse_vector)
	animation_tree.set("parameters/WeaponLeft/blend_position", mouse_vector)
	animation_tree.set("parameters/WindupRight/blend_position", mouse_vector)
	animation_tree.set("parameters/WindupLeft/blend_position", mouse_vector)
	animation_tree.set("parameters/AttackRight/blend_position", mouse_vector)
	animation_tree.set("parameters/AttackLeft/blend_position", mouse_vector)
	
	# Only switch between left and right if in IDLE state
	if current_state == WeaponState.IDLE and new_direction != last_direction:
		animation_state_machine.travel("Weapon"+new_direction)
		last_direction = new_direction

func start_windup(mouse_vector: Vector2):
	if current_state != WeaponState.IDLE:
		return
	var direction = "Right" if mouse_vector.x >= 0 else "Left"
	animation_state_machine.travel("Windup"+direction)

func release_attack(mouse_vector: Vector2):
	if current_state != WeaponState.WINDUP:
		return
	var direction = "Right" if mouse_vector.x >= 0 else "Left"
	animation_state_machine.travel("Attack"+direction)
	attack_timer.start()

func on_attack_timer_timeout():
	current_state = WeaponState.IDLE
	# Return to the appropriate idle state
