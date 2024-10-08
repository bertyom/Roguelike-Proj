extends CharacterBody2D
class_name EnemyBase

#Universal node references
#@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var weapon_container: Node2D = $WeaponContainer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var hp_bar: TextureProgressBar = $EnemyHPBar
@onready var ai_states: Node2D = $States


#Universal humanoid stats
@export var max_hp: int = 100
@export var knockback_resistance: int = 2
@export var movement_speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_radius: float = 50.0

#Operational variables
var current_hp: int
var starting_position: Vector2 
#var current_state: State
var target: Node2D
var knockback_velocity: Vector2 = Vector2.ZERO

func ready():
	ai_states.parent_node = self
	starting_position = get_global_position()
	update_hp_bar()

func take_damage(amount: int, knockback: float, attacker_position: Vector2):
	current_hp -= amount
	update_hp_bar()
	if knockback > 0:
		apply_knockback(knockback, attacker_position)
		if knockback > knockback_resistance:
			ai_states.change_state("Knockback")
	if current_hp <= 0:
		ai_states.change_state("Dead")
		
func apply_knockback(force: float, source_position: Vector2):
	var knockback_direction = (global_position - source_position).normalized()
	knockback_velocity = knockback_direction * force

func update_hp_bar():
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	if current_hp == max_hp or current_hp == 0:
		hp_bar.visible = false
