extends Node2D
class_name Weapon

#emitted via animation player
signal attack_windup
signal attack_ended

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
@onready var weapon_manager = get_parent()

var last_direction: String
var attack_direction: String
var attack_vector: Vector2

func _ready():
	attack_timer.wait_time = attack_cooldown
	attack_timer.connect("timeout", on_attack_timer_timeout)
	connect("attack_windup", weapon_manager._on_weapon_windup_started)
	connect("attack_ended", weapon_manager._on_weapon_attack_ended)

func update_weapon_rotation(mouse_vector: Vector2):
	var new_direction = "Right" if mouse_vector.x >= 0 else "Left"
	
	# Update blend position for idle states only
	animation_tree.set("parameters/WeaponRight/blend_position", mouse_vector)
	animation_tree.set("parameters/WeaponLeft/blend_position", mouse_vector)
	
	# Only switch between left and right if in IDLE state
	if current_state == WeaponState.IDLE and new_direction != last_direction:
		animation_state_machine.travel("Weapon"+new_direction)
		last_direction = new_direction

#FIXME is_stopped is a crutch, fix the fucking cooldown state
func start_windup(mouse_vector: Vector2):
	if current_state != WeaponState.IDLE or !attack_timer.is_stopped():
		return
	else:
		current_state = WeaponState.WINDUP
		attack_direction = "Right" if mouse_vector.x >= 0 else "Left"
		attack_vector = mouse_vector
		animation_tree.set("parameters/Windup"+attack_direction+"/blend_position", attack_vector)
		animation_state_machine.travel("Windup"+attack_direction)

func release_attack():
	if current_state != WeaponState.WINDUP or !attack_timer.is_stopped():
		return
	else:
		current_state = WeaponState.ATTACKING
		animation_tree.set("parameters/Attack"+attack_direction+"/blend_position", attack_vector)
		animation_state_machine.travel("Attack"+attack_direction)
		attack_timer.start()

#FIXME state automatically sets to IDLE when attackign animation ends, cannot find the cause yet
func on_attack_timer_timeout():
	current_state = WeaponState.IDLE
