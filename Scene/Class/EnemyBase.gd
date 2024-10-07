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

#Universal humanoid stats
@export var max_hp: int = 100
@export var movement_speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_radius: float = 50.0

#Operational variables
var current_hp: int
#var current_state: State
var target: Node2D
var knockback_velocity: Vector2 = Vector2.ZERO
