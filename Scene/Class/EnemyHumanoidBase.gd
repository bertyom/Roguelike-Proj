extends CharacterBody2D
class_name EnemyHumanoidBase

#Universal node references
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree = $AnimationPlayer/AnimationTree["parameters/playback"]
@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var weapon_container: Node2D = $WeaponContainer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_detection_area: Area2D = $DetectionBox
@onready var hp_bar: TextureProgressBar = $EnemyHPBar
@onready var icon_popup: Control = $EnemyIconPopup
@onready var ai_states: Node = $States
const dead_body_template = preload("res://Scene/Entity/Enemy/Components/DeadBody.tscn")
const damage_indicator_template = preload("res://Scene/UI/Enemy UI/DamageIndicator.tscn")

#Universal humanoid stats
@export var max_hp: int = 10
@export var knockback_resistance: int = 2
@export var movement_speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_radius: float = 50.0

#Operational variables
var facing_right: bool
var lost_position: Vector2i
@export var current_hp: int
var starting_position: Vector2 
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready():
	current_hp = max_hp
	ai_states.parent_node = self
	starting_position = get_global_position()
	update_hp_bar()
	hurtbox.connect("area_entered", _on_hurtbox_area_entered)
	setup_weapon_container()

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

#region UI
func update_hp_bar():
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	if current_hp == max_hp or current_hp <= 0:
		hp_bar.visible = false
	elif current_hp < max_hp:
		hp_bar.visible = true

func display_alert_popup():
	icon_popup.get_node("EnemyAlertIcon").start()

func display_lost_popup():
	icon_popup.get_node("EnemyLostIcon").start()

func _show_damage_indicator(damage):
	var damage_indicator = damage_indicator_template.instantiate()
	damage_indicator.global_position = self.global_position + Vector2(randi_range(-20, 0), randi_range(-10, -30))
	get_tree().root.add_child(damage_indicator)
	damage_indicator.start(damage)
#endregion

func take_damage(amount: int, knockback: float, attacker_position: Vector2):
	current_hp -= amount
	update_hp_bar()
	_show_damage_indicator(amount)
	_unknown_hurt(attacker_position)
	if knockback > 0:
		if knockback > knockback_resistance and current_hp > 0:
			ai_states.temp_change_state("Stagger", 0.2)
		apply_knockback(knockback*5, attacker_position)
	if current_hp <= 0:
		weapon_container.visible = false
		ai_states.change_state("Dead")

func _unknown_hurt(location):
	if ai_states.active_state.behaviour_type == "Passive":
		display_lost_popup()
		if location != null:
			lost_position = location
		else:
			lost_position = PlayerData.player_node.get_global_position()

func apply_knockback(force: float, source_position: Vector2):
	var knockback_direction = (global_position - source_position).normalized()
	velocity = knockback_direction * force
	move_and_slide()
		
func _spawn_dead_body():
	# Create an instance of the dead body scene
	var dead_body = dead_body_template.instantiate()
	dead_body._setup(self)
	get_parent().add_child(dead_body)
	queue_free()

func _on_hurtbox_area_entered(area: Area2D):
	take_damage(area.get_meta("Attack"), area.get_meta("Knockback"), area.global_position)

func _on_detection_box_body_entered(body: Node2D):
	if body is Player:
		print("Hello there")

func setup_weapon_container():
	weapon_container.controlled_body = self
	weapon_container.setup()
