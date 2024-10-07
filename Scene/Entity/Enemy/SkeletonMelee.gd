extends CharacterBody2D
var movement_speed = 125
var knockback_velocity = Vector2()
@onready var hp_bar = get_node("EnemyHPBar")
@onready var ai_container = get_node("AI Container")
@export var active_state: String = "Chase"
var starting_position = Vector2.ZERO
@export var max_hp: int = 35
@export var current_hp: int = 5
signal get_damaged
var lost_position
@onready var attack_range = $AttackRange
@onready var sprite = $Sprite
@onready var anim_player = $AnimationPlayer/AnimationTree
@onready var anim_tree = anim_player["parameters/playback"]
@onready var hurtbox = $Hurtbox
@onready var detection_box = $DetectionBox
@onready var undetection_box = $UnDetectionBox
@onready var icon_popup = $EnemyIconPopup
var current_weapon
var facing_right: bool
var old_state
var two_state
@onready var weapon_container = $WeaponContainer
var damage_indicator = preload("res://Scenes/GUI/DamageIndicator.tscn")
var dead_body_template = preload("res://Scenes/Characters/Enemies/CNT_DeadBody.tscn")
var should_change_state
var future_state
@onready var soft_collision = $SoftCollision
var push_vector

func _ready():
	ai_container = get_node("AI Container")
	change_state(active_state)
	starting_position = get_global_position()
	detection_box.area_entered.connect(_on_DetectionBox_area_entered)
	undetection_box.area_exited.connect(_on_UnDetectionBox_area_exited)
	hurtbox.area_entered.connect(_on_Hurtbox_area_entered)
	if current_hp < max_hp:
		hp_bar.visible = true
	_select_random_weapon()

func _get_soft_collision_vector():
	push_vector = soft_collision.get_push_vector()

func _get_damaged(damage, location):
	current_hp -= damage
	if hp_bar.visible == false:
		hp_bar.visible = true
	if current_hp <= 0:
		change_state("Dead")
		current_weapon.visible = false
		hp_bar.visible = false
	hp_bar._on_get_damage()
	_unknown_hurt(location)

func _select_random_weapon(): #pick a random weapon from the weapon container
	current_weapon = weapon_container.get_child(randf_range(0, weapon_container.get_child_count()))
	for child in weapon_container.get_children():
		if child != current_weapon:
			child.visible = false
		else:
			child.visible = true
	attack_range.start()
	attack_range.area_exited.connect(_on_player_outta_attack_range)

func is_player_in_attack_range():
	for area in attack_range.get_overlapping_areas():
		if area.name == "DetectionShape":
			return true
	return false
	
func _on_player_outta_attack_range(area):
	if ai_container.get_node("WeaponAttackMelee").currently_swinging:
		should_change_state = true
		future_state = "Chase"

func _show_damage_indicator(damage):
	var damage_indicator_instance = damage_indicator.instantiate()
	damage_indicator_instance.global_position = self.global_position + Vector2(randf_range(-20, 0), randf_range(-10, -30))
	get_tree().root.add_child(damage_indicator_instance)
	damage_indicator_instance.start(damage)
	
func _get_knockback(knockback):
	var knocback_vector = (self.global_position - PlayerData.player_node.global_position).normalized()
	knockback_velocity = knocback_vector * knockback * 500
	if knockback > 2:
		temp_change_state("Stagger", 0.2)

func _physics_process(delta):
	_get_soft_collision_vector()
	
	if is_player_in_attack_range() and !(active_state in ["WeaponAttackMelee", "Dead", "Stagger"]) and current_hp > 0:
		change_state("WeaponAttackMelee")

	if !sprite.flip_h:
		facing_right = true
		if active_state != "Dead" or active_state != "WeaponAttackMelee":
			current_weapon.anim_state_machine.travel("Right")
	else:
		facing_right = false
		if active_state != "Dead" or active_state != "WeaponAttackMelee":
			current_weapon.anim_state_machine.travel("Left")
			
	if knockback_velocity.length() > 0:
		var motion = knockback_velocity * delta
		velocity = motion
		move_and_slide()
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5 * delta)
	if active_state == "WeaponAttackMelee":
		if should_change_state and  ai_container.get_node(active_state).currently_swinging == false and current_hp > 0:
			change_state(future_state)
			should_change_state = false

func _on_Hurtbox_area_entered(area):
	if current_hp > 0:
		var damage = area.weapon_base_damage
		var knockback = area.weapon_base_knockback
		if area.location != null:
			var location = area.location
			_get_damaged(damage, location)
		else:
			_get_damaged(damage, null)
		_show_damage_indicator(damage)
		_get_knockback(knockback)
	
func _on_DetectionBox_area_entered(area):
	if active_state != "Dead" and not is_player_in_attack_range():
		if active_state != "Chase":
			icon_popup.get_node("EnemyAlertIcon").start()
		change_state("Chase")

func _unknown_hurt(location):
	if ai_container.get_node(active_state).behaviour_type == "Passive":
		icon_popup.get_node("EnemyLostIcon").start()
		if location != null:
			lost_position = location
		else:
			lost_position = PlayerData.player_node.get_global_position()
		change_state("Seek")

func _on_UnDetectionBox_area_exited(area):
	if active_state == "Chase":
		lost_position = PlayerData.player_node.get_global_position()
		icon_popup.get_node("EnemyLostIcon").start()
		change_state("Seek")

func _spawn_dead_body():
	# Create an instance of the dead body scene
	var dead_body = dead_body_template.instantiate()

	# Get the sprite node of the dead body
	var dead_body_sprite = dead_body.get_node("Sprite")

	# Set the properties of the dead body's sprite to match the enemy's sprite
	dead_body_sprite.texture = sprite.texture
	dead_body_sprite.hframes = sprite.hframes
	dead_body_sprite.vframes = sprite.vframes
	dead_body_sprite.frame = sprite.frame
	dead_body_sprite.flip_h = sprite.flip_h
	dead_body_sprite.centered = sprite.centered

	# Set the position of the dead body to match the enemy's position
	dead_body.global_position = global_position

	# Set the position of the dead body's sprite to match the enemy's sprite position
	dead_body_sprite.position = sprite.position

	# Add the dead body to the current scene
	get_parent().add_child(dead_body)
	queue_free()

func _on_Return():
	change_state("Idle")

func temp_change_state(new_state, time):
	if !ai_container.get_node("TempTimer").timeout.is_connected(_on_temp_state_timer):
		ai_container.get_node("TempTimer").timeout.connect(_on_temp_state_timer)
	old_state = active_state
	ai_container.get_node(active_state).set_process(false)
	active_state = new_state
	ai_container.get_node(active_state).set_process(true)
	ai_container.get_node("TempTimer").start(time)

func _on_temp_state_timer():
	change_state(old_state)

func change_state(new_state):
	if ai_container.get_node(active_state).has_method("stop"):
		ai_container.get_node(active_state).stop()
	ai_container.get_node(active_state).set_physics_process(false)
	if ai_container.get_node(new_state).has_method("start"):
		ai_container.get_node(new_state).start()
	active_state = new_state
	ai_container.get_node(active_state).set_physics_process(true)
