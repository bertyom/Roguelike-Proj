extends CharacterBody2D
class_name EnemyBase

#Universal node references
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree = $AnimationPlayer/AnimationTree["parameters/playback"]
@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
#@onready var weapon_container: Node2D = $WeaponContainer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
#@onready var detection_area: Area2D = $DetectionArea
#@onready var attack_area: Area2D = $AttackArea
@onready var hp_bar: TextureProgressBar = $EnemyHPBar
@onready var ai_states: Node = $States
const dead_body_template = preload("res://Scene/Entity/Enemy/Components/DeadBody.tscn")

#Universal humanoid stats
@export var max_hp: int = 10
@export var knockback_resistance: int = 2
@export var movement_speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_radius: float = 50.0

#Operational variables
var facing_right: bool
@export var current_hp: int
var starting_position: Vector2 
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready():
	current_hp = max_hp
	ai_states.parent_node = self
	starting_position = get_global_position()
	update_hp_bar()
	hurtbox.connect("area_entered", _on_hurtbox_area_entered)

func _physics_process(_delta):
	_is_facing_right()

func _is_facing_right():
	if velocity != Vector2.ZERO:
		if velocity.x > 0:
			facing_right = true
		else:
			facing_right = false
	else:
		facing_right = !sprite.flip_h
	
func take_damage(amount: int, knockback: float, attacker_position: Vector2):
	current_hp -= amount
	update_hp_bar()
	if knockback > 0:
		apply_knockback(knockback*5, attacker_position)
		if knockback > knockback_resistance and current_hp > 0:
			ai_states.temp_change_state("Stagger", 0.2)
	if current_hp <= 0:
		ai_states.change_state("Dead")
		
func apply_knockback(force: float, source_position: Vector2):
	var knockback_direction = (global_position - source_position).normalized()
	velocity = knockback_direction * force
	move_and_slide()

func update_hp_bar():
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	if current_hp == max_hp or current_hp <= 0:
		hp_bar.visible = false
	elif current_hp < max_hp:
		hp_bar.visible = true
		
func _spawn_dead_body():
	# Create an instance of the dead body scene
	var dead_body = dead_body_template.instantiate()
	dead_body._setup(self)
	get_parent().add_child(dead_body)
	queue_free()

func _on_hurtbox_area_entered(area: Area2D):
	take_damage(area.get_meta("Attack"), area.get_meta("Knockback"), area.position)
